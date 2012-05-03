##### BEGIN CICERO-BOILERPLATE CODE  #####
# Sets up a standard set of routes according to the Cicero API.
#
# TODO(cgb): The user may have their own imports in the code - consider
# automatically placing them in as well.

try:
  import simplejson as json
except ImportError:
  import json

import datetime
import logging
import os
import StringIO
import wsgiref.handlers
import base64

# Enable HTTP debugging http://stackoverflow.com/q/5022945
import httplib
httplib.HTTPConnection.debuglevel = 1

# NOTE: We use blob storage instead of db because `winazurestorage` does not
# support editing Table Storage, only Blob Storage.
import winazurestorage as azure
import webapp2

import {{ package_name }}

blob = None
if 'AZURE_STORAGE_ACCOUNT' in os.environ and 'AZURE_STORAGE_SECRET_KEY' in os.environ \
    and os.environ['AZURE_STORAGE_ACCOUNT'] and os.environ['AZURE_STORAGE_SECRET_KEY']:
  blob = azure.BlobStorage(azure.CLOUD_BLOB_HOST, os.environ['AZURE_STORAGE_ACCOUNT'], os.environ['AZURE_STORAGE_SECRET_KEY'])
else:
  blob = azure.BlobStorage() # use local dev storage

def get_container(namespace):
  name = "cicero-{{ app_id }}" + namespace

  # Check that it doesn't exist already.
  for container in blob.list_containers():
    if container[0] == name: return name

  # Otherwise, create it.
  code = blob.create_container(name)
  return name

class TaskRoute(webapp2.RequestHandler):
  def get(self):
    key_name = self.request.get('task_id')
    logging.debug("looking up task info for task id " + key_name)
    task_info = json.loads(blob.get_blob(get_container('tasks'), key_name))
    result = {} # TODO - see if we can remove that
    try:
      result = {'result':'success', 'state':task_info['state']}
    except AttributeError:
      result = {'result':'failure', 'state':'not found'}

    str_result = json.dumps(result)
    logging.debug("task info for task id " + key_name + " is " + str_result)
    self.response.out.write(str_result)

  def put(self):
    allowed_routes = ['{{ function_name }}']
    function = self.request.get('f')
    input_source = self.request.get('input1')
    json_data = {'f':function, 'input1':input_source}

    output = ''
    if self.request.get('output') == '':
      key_length = 16  # for now, randomly generates keys 16 chars long
      json_data['output'] = base64.b64encode(os.urandom(key_length))  # TODO - does this work in app engine?
    else:
      json_data['output'] = str(self.request.get('output'))
    output = str(json_data['output'])

    if function in allowed_routes:
      url = '/' + function
      logging.debug('starting a request for url ' + url)

      # Just compute inline. TODO: Compute in background, using Azure task queues.
      compute(json.dumps(json_data))

      task_name = base64.b64encode(os.urandom(key_length))
      result = {'result':'success', 'task_id':task_name, 'output':output, 'id':task_name}
      logging.debug('result of job with input data' + str(json_data) + ' was ' + str(result))
      self.response.out.write(json.dumps(result))
    else:
      reason = 'Cannot add a task for function type ' + str(function)
      result ={'result':'failure', 'reason':reason}
      self.response.out.write(json.dumps(result))

  def delete(self):
    # NOOP
    result = {'result':'unknown', 'reason':str(cancel_info)}
    self.response.out.write(result)


class DataRoute(webapp2.RequestHandler):
  def get(self):
    key_name = self.request.get('location')
    output = json.loads(blob.get_blob(get_container('texts'), key_name))
    result = {} # TODO - see if we can remove that
    try:
      result = {'result':'success', 'output':output['content']}
    except AttributeError:
      result = {'result':'failure', 'reason':'key did not exist'}

    self.response.out.write(json.dumps(result))

  def put(self):
    key_name = self.request.get('location')
    output = {'key_name': key_name}
    output['content'] = self.request.get('text')
    blob.put_blob(get_container('texts'), key_name, json.dumps(output))

    result = {'result':'success'}
    self.response.out.write(json.dumps(result))

  def delete(self):
    key_name = self.request.get('location')

    result = {}
    try:
      blob.delete_blob(get_container('texts'), key_name)
      result = {'result':'success'}
    except Exception:
      result = {'result':'failure', 'reason':'exception was thrown'} # TODO get the name of the exception here

    self.response.out.write(result)


def compute(data):
  logging.debug("starting a new task")
  raw_data = data
  json_data = json.loads(raw_data)
  input_source = str(json_data['input1'])
  output_dest = str(json_data['output'])
  task_id = output_dest  # TODO(cgb) - find a way to make me the task's id

  logging.debug("adding info about new task, with id " + task_id)
  task_info = {'key_name': task_id}
  task_info['state'] = "started"
  task_info['start_time'] = datetime.datetime.now()
  blob.put_blob(get_container('tasks'), task_id, json.dumps(task_info))

  logging.debug("done adding task info, running task")
  output_text = {'key_name': output_dest}
  output_text['content'] = str({{ package_name }}.{{ function_name }}())
  blob.put_blob(get_container('texts'), output_dest, json.dumps(output_text))

  logging.debug("done running task - updating task metadata")
  task_info = json.loads(blob.get_blob(get_container('tasks'), task_id))
  task_info['state'] = "finished"
  task_info['end_time'] = datetime.datetime.now()
  blob.put_blob(get_container('tasks'), task_id, json.dumps(task_info))

class ComputeWorker(webapp2.RequestHandler):
  def post(self):
    compute(self.request.get('data'))

class IndexPage(webapp2.RequestHandler):
  def get(self):
    # TODO(cgb): write something nicer about oration here!
    self.response.out.write("hello!")

logging.getLogger().setLevel(logging.DEBUG)
app = webapp2.WSGIApplication([('/task', TaskRoute),
                              ('/data', DataRoute),
                              ('/{{ function_name }}', ComputeWorker),
                              ('/', IndexPage),
                              ], debug=True)
def main():
  from rocket import Rocket
  Rocket((os.environ.get('ADDRESS', '0.0.0.0'), int(os.environ.get('PORT', 9000))), 'wsgi', {'wsgi_app': app}).start()

if __name__ == '__main__':
  main()

##### END CICERO-BOILERPLATE CODE  #####
