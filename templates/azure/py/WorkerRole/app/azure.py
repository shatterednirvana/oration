from winazurestorage import *

# NOTE: We use blob storage instead of db because `winazurestorage` does not
# support editing Table Storage, only Blob Storage.
blob = None
if 'AZURE_STORAGE_ACCOUNT_NAME' in os.environ and 'AZURE_STORAGE_ACCESS_KEY' in os.environ \
    and os.environ['AZURE_STORAGE_ACCOUNT_NAME'] and os.environ['AZURE_STORAGE_ACCESS_KEY']:
  blob = azure.BlobStorage(azure.CLOUD_BLOB_HOST, os.environ['AZURE_STORAGE_ACCOUNT_NAME'], os.environ['AZURE_STORAGE_ACCESS_KEY'])
else:
  blob = azure.BlobStorage() # use local dev storage

