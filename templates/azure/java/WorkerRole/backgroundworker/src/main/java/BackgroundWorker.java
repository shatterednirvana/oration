import com.microsoft.windowsazure.services.core.storage.*;
import com.microsoft.windowsazure.services.queue.client.*;
import com.microsoft.windowsazure.services.blob.client.*;

import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import java.io.UnsupportedEncodingException;
import java.io.IOException;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;

public class BackgroundWorker {
  final CloudStorageAccount storageAccount;
  final CloudQueueClient queueClient;
  final CloudQueue taskQueue;

  final CloudBlobClient blobClient;
  final CloudBlobContainer taskContainer;
  final CloudBlobContainer textContainer;
  
  final DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

  public BackgroundWorker() throws URISyntaxException, InvalidKeyException, StorageException {
    storageAccount = CloudStorageAccount.parse(getStorageConnectionString());
    queueClient = storageAccount.createCloudQueueClient();
    taskQueue = queueClient.getQueueReference("cicero-{{ app_id }}-tasks");
    taskQueue.createIfNotExist();

    blobClient = storageAccount.createCloudBlobClient();
    taskContainer = blobClient.getContainerReference("cicero-{{ app_id }}-tasks");
    textContainer = blobClient.getContainerReference("cicero-{{ app_id }}-texts");
    taskContainer.createIfNotExist();
    textContainer.createIfNotExist();
  }

  private String getStorageConnectionString() {
    final String account = System.getenv("AZURE_STORAGE_ACCOUNT_NAME");
    final String accessKey = System.getenv("AZURE_STORAGE_ACCESS_KEY");
    if(account != null && accessKey != null
        && account.length() > 0 && accessKey.length() > 0) {
      return "DefaultEndpointsProtocol=http" + 
        ";AccountName=" + account +
        ";AccountKey=" + accessKey;
    } else {
      return "UseDevelopmentStorage=true";
    }
  }

  public void compute(String json) throws UnsupportedEncodingException, URISyntaxException, StorageException, IOException {
    JSONObject data = (JSONObject) JSONValue.parse(json);
    String id = (String) data.get("id");
    String function = (String) data.get("function");
    String outputLocation = (String) data.get("output_location");
    info("Starting task " + id + " for function " + function);

    info("Updating status of task " + id + ": started");
    JSONObject taskInfo = new JSONObject();
    taskInfo.put("id", id);
    taskInfo.put("status", "started");
    taskInfo.put("start_time", df.format(new Date()));
    byte[] bytes = taskInfo.toJSONString().getBytes("UTF-8");
    taskContainer.getBlockBlobReference(id).upload(
        new ByteArrayInputStream(bytes), bytes.length);

    info("Actually running task " + id);
    String content = ((Object) {{ namespace }}.{{ function_name }}()).toString();

    info("Putting output data into location " + outputLocation);
    JSONObject outputText = new JSONObject();
    outputText.put("location", outputLocation);
    outputText.put("content", content);
    bytes = outputText.toJSONString().getBytes("UTF-8");
    textContainer.getBlockBlobReference(outputLocation).upload(
        new ByteArrayInputStream(bytes), bytes.length);

    info("Updating status of task " + id + ": finished");
    ByteArrayOutputStream taskInfoStream = new ByteArrayOutputStream();
    taskContainer.getBlockBlobReference(id).download(taskInfoStream);
    taskInfo = (JSONObject) JSONValue.parse(taskInfoStream.toString("UTF-8"));
    taskInfo.put("status", "finished");
    taskInfo.put("finish_time", df.format(new Date()));
    bytes = taskInfo.toJSONString().getBytes("UTF-8");
    taskContainer.getBlockBlobReference(id).upload(
        new ByteArrayInputStream(bytes), bytes.length);
  }

  public void start() throws InterruptedException {
    while(true) {
      try {
        debug("Polling for a task");
        CloudQueueMessage message = taskQueue.retrieveMessage();
        if(message == null) continue;
        info("Received a task");
        compute(message.getMessageContentAsString());
        taskQueue.deleteMessage(message);
      } catch(Exception e) {
        e.printStackTrace();
      } finally {
        Thread.sleep(10*1000);
      }
    }
  }

  private void info(String message) {
    System.err.println(message);
  }

  private final boolean isDebug = false;
  private void debug(String message) {
    if(isDebug) System.err.println(message);
  }

  public static void main(String[] args) throws URISyntaxException, InvalidKeyException, StorageException, InterruptedException {
    new BackgroundWorker().start();
  }
}
