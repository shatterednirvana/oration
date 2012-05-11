from winazurestorage import *

account = None
access_key = None
if 'AZURE_STORAGE_ACCOUNT_NAME' in os.environ and 'AZURE_STORAGE_ACCESS_KEY' in os.environ \
    and os.environ['AZURE_STORAGE_ACCOUNT_NAME'] and os.environ['AZURE_STORAGE_ACCESS_KEY']:
  account = os.environ['AZURE_STORAGE_ACCOUNT_NAME']
  access_key = os.environ['AZURE_STORAGE_ACCESS_KEY']

# NOTE: We use blob storage instead of db because `winazurestorage` does not
# support editing Table Storage, only Blob Storage.

# Use cloud if account and access key given, otherwise use local dev storage
blob = BlobStorage(CLOUD_BLOB_HOST, account, access_key) if account and access_key else BlobStorage()
queue = QueueStorage(CLOUD_QUEUE_HOST, account, access_key) if account and access_key else QueueStorage()

def get_container(namespace):
  name = "cicero-{{ app_id }}-" + namespace

  # Check that it doesn't exist already.
  for container in blob.list_containers():
    if container[0] == name: return name

  # Otherwise, create it.
  code = blob.create_container(name)
  return name

def get_queue(namespace):
  name = "cicero-{{ app_id }}-" + namespace

  # Create it (returns 2xx if already exists)
  queue.create_queue(name)
  return name
