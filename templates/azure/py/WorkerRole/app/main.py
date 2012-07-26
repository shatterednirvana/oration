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
from urllib2 import HTTPError
httplib.HTTPConnection.debuglevel = 1

from azure import blob, get_container, queue, get_queue
import webapp2

class TaskRoute(webapp2.RequestHandler):
  def get(self):
    key_name = self.request.get('task_id')
    logging.debug("looking up task info for task id " + key_name)
    result = {} # TODO - see if we can remove that
    try:
      task_info = json.loads(blob.get_blob(get_container('tasks'), key_name))
      result = {'result': 'success', 'state': task_info['state']}
    except HTTPError as e:
      if e.code == 404:
        result = {'result':'failure', 'reason':'not found'}
      else:
        raise e
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
      json_data['output'] = base64.b64encode(os.urandom(key_length), '-_')  # TODO - does this work in app engine?
    else:
      json_data['output'] = str(self.request.get('output'))
    output = str(json_data['output'])

    if function in allowed_routes:
      url = '/' + function
      logging.debug('starting a request for url ' + url)

      queue.put_message(get_queue('tasks'), json.dumps(json_data))

      key_length = 16
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
    result = {} # TODO - see if we can remove that
    try:
      output = json.loads(blob.get_blob(get_container('texts'), key_name))
    except HTTPError as e:
      if e.code == 404:
        result = {'result':'failure', 'reason':'key did not exist'}
      else:
        raise e
    else:
      result = {'result':'success', 'output':output['content']}
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

class IndexPage(webapp2.RequestHandler):
  def get(self):
    # TODO(cgb): write something nicer about oration here!
    self.response.out.write("hello!")

logging.getLogger().setLevel(logging.DEBUG)
app = webapp2.WSGIApplication([('/task', TaskRoute),
                              ('/data', DataRoute),
                              ('/', IndexPage),
                              ], debug=True)
def main():
  from rocket import Rocket
  Rocket((os.environ.get('ADDRESS', '0.0.0.0'), int(os.environ.get('PORT', 9000))), 'wsgi', {'wsgi_app': app}).start()

if __name__ == '__main__':
  main()

##### END CICERO-BOILERPLATE CODE  #####
