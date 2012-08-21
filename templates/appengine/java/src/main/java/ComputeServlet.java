import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Text;

import java.util.logging.Logger;

@SuppressWarnings("serial")
public class ComputeServlet extends HttpServlet {
	private static final DatastoreService datastore =
    DatastoreServiceFactory.getDatastoreService();
  private static final Logger log =
    Logger.getLogger(ComputeServlet.class.getName());
  private static final DateFormat df =
    new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
    JSONObject data = (JSONObject) JSONValue.parse(req.getParameter("data"));
    final String id = (String) data.get("id");
    final String function = (String) data.get("function");
    final String outputLocation = (String) data.get("output_location");
    log.info("Starting task " + id + " for function " + function);

    log.info("Updating status of task " + id + ": started");
    Entity taskInfo = new Entity("Task", id);
    taskInfo.setProperty("id", id);
    taskInfo.setProperty("status", "started");
    taskInfo.setProperty("start_time", df.format(new Date()));
    datastore.put(taskInfo);

    log.info("Actually running task " + id);
    String content = ((Object) {{#namespace}}{{namespace}}{{/namespace}}.{{ function_name }}()).toString();

    log.info("Putting output data into location " + outputLocation);
    Entity model = new Entity("Data", outputLocation);
    model.setProperty("location", outputLocation);
    model.setProperty("content", new Text(content));
    datastore.put(model);

    log.info("Updating status of task " + id + ": finished");
    taskInfo.setProperty("status", "finished");
    taskInfo.setProperty("finish_time", df.format(new Date()));
    datastore.put(taskInfo);
  }
}
