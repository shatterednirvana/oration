import time
import json
import datetime
import logging
import traceback

from azure import blob, get_container, queue, get_queue
import {{ package_name }}

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
  task_info['start_time'] = datetime.datetime.now().isoformat()
  blob.put_blob(get_container('tasks'), task_id, json.dumps(task_info))

  logging.debug("done adding task info, running task")
  output_text = {'key_name': output_dest}
  output_text['content'] = str({{ package_name }}.{{ function_name }}())
  blob.put_blob(get_container('texts'), output_dest, json.dumps(output_text))

  logging.debug("done running task - updating task metadata")
  task_info = json.loads(blob.get_blob(get_container('tasks'), task_id))
  task_info['state'] = "finished"
  task_info['end_time'] = datetime.datetime.now().isoformat()
  blob.put_blob(get_container('tasks'), task_id, json.dumps(task_info))

logging.getLogger().setLevel(logging.DEBUG)

def main():
  while True:
    try:
      logging.debug("Polling for a task.")
      msg = queue.get_message(get_queue('tasks'))
      if not msg: continue
      compute(msg.text)
      queue.delete_message(get_queue('tasks'), msg)
    except:
      logging.error(traceback.format_exc())
    finally:
      time.sleep(10)

if __name__ == '__main__':
  main()
