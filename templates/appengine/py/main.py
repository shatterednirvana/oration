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

from google.appengine.api import taskqueue
from google.appengine.ext import db
import webapp2

import {{ package_name }}

class TaskInfo(db.Model):
  state = db.StringProperty()
  start_time = db.DateTimeProperty()
  end_time = db.DateTimeProperty()


class Text(db.Model):
  content = db.TextProperty()


class TaskRoute(webapp2.RequestHandler):
  def get(self):
    key_name = self.request.get('task_id')
    logging.debug("looking up task info for task id " + key_name)
    task_info = TaskInfo.get_by_key_name(key_name)
    result = {} # TODO - see if we can remove that
    try:
      result = {'result':'success', 'state':task_info.state}
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
      new_task = taskqueue.add(url=url, params={'data': json.dumps(json_data)})
      # TODO - adding the task does not imply success - when does it not?
      result = {'result':'success', 'task_id':new_task.name, 'output':output, 'id':new_task.name}
      logging.debug('result of job with input data' + str(json_data) + ' was ' + str(result))
      self.response.out.write(json.dumps(result))
    else:
      reason = 'Cannot add a task for function type ' + str(function)
      result ={'result':'failure', 'reason':reason}
      self.response.out.write(json.dumps(result))

  def delete(self):
    task_id = self.request.get('task_id')
    task = taskqueue.Task(name=task_id)
    q = taskqueue.Queue()
    cancel_info = q.delete_tasks(task)
    logging.debug('cancel_info is ' + str(cancel_info))
    result = {'result':'unknown', 'reason':str(cancel_info)}
    self.response.out.write(result)


class DataRoute(webapp2.RequestHandler):
  def get(self):
    key_name = self.request.get('location')
    output = Text.get_by_key_name(key_name)
    result = {} # TODO - see if we can remove that
    try:
      result = {'result':'success', 'output':output.content}
    except AttributeError:
      result = {'result':'failure', 'reason':'key did not exist'}

    self.response.out.write(json.dumps(result))

  def put(self):
    key_name = self.request.get('location')
    output = Text(key_name = key_name)
    output.content = self.request.get('text')
    output.put()

    result = {'result':'success'}
    self.response.out.write(json.dumps(result))

  def delete(self):
    key_name = self.request.get('location')

    text = Text(key_name = key_name)
    result = {}
    try:
      text.delete()
      result = {'result':'success'}
    except Exception:
      result = {'result':'failure', 'reason':'exception was thrown'} # TODO get the name of the exception here

    self.response.out.write(result)


class ComputeWorker(webapp2.RequestHandler):
  def post(self):
    logging.debug("starting a new task")
    raw_data = self.request.get('data')
    json_data = json.loads(raw_data)
    input_source = str(json_data['input1'])
    output_dest = str(json_data['output'])
    task_id = output_dest  # TODO(cgb) - find a way to make me the task's id

    logging.debug("adding info about new task, with id " + task_id)
    task_info = TaskInfo(key_name = task_id)
    task_info.state = "started"
    task_info.start_time = datetime.datetime.now()
    task_info.put()

    logging.debug("done adding task info, running task")
    output_text = Text(key_name = output_dest)
    output_text.content = str({{ package_name }}.{{ function_name }}())
    output_text.put()

    logging.debug("done running task - updating task metadata")
    task_info = TaskInfo.get_by_key_name(task_id)
    task_info.state = "finished"
    task_info.end_time = datetime.datetime.now()
    task_info.put()


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
  app.run()

if __name__ == '__main__':
  main()

##### END CICERO-BOILERPLATE CODE  #####
