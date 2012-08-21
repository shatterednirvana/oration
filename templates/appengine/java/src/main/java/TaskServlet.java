import static com.google.appengine.api.taskqueue.TaskOptions.Builder.withUrl;

import java.io.IOException;
import java.util.Date;
import java.util.Map;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.UUID;
import java.util.concurrent.Callable;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.taskqueue.Queue;
import com.google.appengine.api.taskqueue.QueueFactory;
import com.google.appengine.api.taskqueue.TaskOptions;

import java.util.logging.Logger;

@SuppressWarnings("serial")
public class TaskServlet extends HttpServlet {
	private static final Queue queue = QueueFactory.getDefaultQueue();
	private static final DatastoreService datastore =
    DatastoreServiceFactory.getDatastoreService();
  private static final Logger log =
    Logger.getLogger(TaskServlet.class.getName());

	@Override
	protected void doGet(final HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
    String i_ = req.getParameter("id");
    final String id = (i_ == null) ? req.getParameter("task_id") : i_;

    log.info("Getting status of task " + id);
    try {
      Entity model = datastore.get(
          KeyFactory.createKey("Task", req.getParameter("id")));

      Map<String, Object> taskInfo = new HashMap<String, Object>(
          model.getProperties());
      taskInfo.put("result", "success");
      resp.getWriter().print(JSONValue.toJSONString(taskInfo));
    } catch(EntityNotFoundException e) {
      resp.getWriter().print("{\"result\": \"failure\", \"reason\": \"not found\"}");
    }
  }

	@Override
	protected void doPut(final HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
    String allowedFunction = "{{ function_name }}";
    String f_ = req.getParameter("function");
    final String function = (f_ == null) ? req.getParameter("f") : f_;

    int keyLength = 16;
    String i_ = req.getParameter("id");
    final String id = (i_ == null) ? getUUID().substring(0, keyLength) : i_;

    String o_1 = req.getParameter("output_location");
    String o_2 = req.getParameter("output");
    final String outputLocation = (o_1 == null) ? ((o_2 == null) ?
      getUUID().substring(0, keyLength) : o_2) : o_1;

    log.info("Posting task " + id + " for function " + function);

    {{=<< >>=}}
    if(function.equals(allowedFunction)) {
      TaskOptions taskOptions = withUrl("/compute").taskName(id);
      taskOptions.param("data", new JSONObject() {{
        put("function", function);
        put("id", id);
        put("output_location", outputLocation);
      }}.toString());
      queue.add(taskOptions);

      resp.getWriter().print(new JSONObject() {{
        put("result", "success");
        put("id", id);
        put("output_location", outputLocation);
      }}.toString());
    } else {
      resp.getWriter().print(new JSONObject() {{
        put("result", "failure");
        put("reason", "Cannot add a task for function type " + function);
      }}.toString());
    }
    <<={{ }}=>>
  }

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		doPut(req, resp);
	}
	
	@Override
	protected void doDelete(final HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
    // REGRESSION:
    log.info("NOT cancelling task: not implemented");
    resp.getWriter().print("{\"result\": \"not implemented\"}");
	}
	
	private String getUUID() {
		return UUID.randomUUID().toString();
	}
	
}
