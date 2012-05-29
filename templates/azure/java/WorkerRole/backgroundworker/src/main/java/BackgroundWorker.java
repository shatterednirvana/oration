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
    log("================================ COMPUTING ========================");
    JSONObject data = (JSONObject) JSONValue.parse(json);
    String inputSource = (String) data.get("input1");
    String outputDest = (String) data.get("output");
    String taskId = outputDest;

    log("adding info about new task, with id " + taskId);
    JSONObject taskInfo = new JSONObject();
    taskInfo.put("key_name", taskId);
    taskInfo.put("state", "started");
    taskInfo.put("start_time", df.format(new Date()));
    byte[] bytes = taskInfo.toJSONString().getBytes("UTF-8");
    taskContainer.getBlockBlobReference(taskId).upload(
        new ByteArrayInputStream(bytes), bytes.length);

    log("done adding task info, running task");
    JSONObject outputText = new JSONObject();
    outputText.put("key_name", outputDest);
    outputText.put("content", ((Object) {{ namespace }}.{{ function_name }}()).toString());
    bytes = outputText.toJSONString().getBytes("UTF-8");
    textContainer.getBlockBlobReference(outputDest).upload(
        new ByteArrayInputStream(bytes), bytes.length);

    log("done running task - updating task metadata");
    ByteArrayOutputStream taskInfoStream = new ByteArrayOutputStream();
    taskContainer.getBlockBlobReference(taskId).download(taskInfoStream);
    taskInfo = (JSONObject) JSONValue.parse(taskInfoStream.toString("UTF-8"));
    taskInfo.put("state", "finished");
    taskInfo.put("end_time", df.format(new Date()));
    bytes = taskInfo.toJSONString().getBytes("UTF-8");
    taskContainer.getBlockBlobReference(taskId).upload(
        new ByteArrayInputStream(bytes), bytes.length);
  }

  public void start() throws InterruptedException {
    while(true) {
      try {
        log("Polling for a task.");
        CloudQueueMessage message = taskQueue.retrieveMessage();
        if(message == null) continue;
        compute(message.getMessageContentAsString());
        taskQueue.deleteMessage(message);
      } catch(Exception e) {
        e.printStackTrace();
      } finally {
        Thread.sleep(10*1000);
      }
    }
  }

  private void log(String message) {
    System.err.println(message);
  }

  public static void main(String[] args) throws URISyntaxException, InvalidKeyException, StorageException, InterruptedException {
    new BackgroundWorker().start();
  }
}
