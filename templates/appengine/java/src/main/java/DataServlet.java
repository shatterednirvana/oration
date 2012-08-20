import java.io.IOException;
import java.util.concurrent.Callable;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONObject;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Text;

import java.util.logging.Logger;

@SuppressWarnings("serial")
public class DataServlet extends HttpServlet {
	private static final DatastoreService datastore =
    DatastoreServiceFactory.getDatastoreService();
  private static final Logger log =
    Logger.getLogger(DataServlet.class.getName());
	
	@Override
	protected void doGet(final HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
    String location = req.getParameter("location");
    log.info("Getting data at location " + location);

    try {
      {{=<< >>=}}
      final Entity model = datastore.get(KeyFactory.createKey("Data", location));
      resp.getWriter().print(new JSONObject() {{
        put("result", "success");
        put("output", ((Text) model.getProperty("content")).getValue());
      }}.toString());
      <<={{ }}=>>
    } catch(EntityNotFoundException e) {
      resp.getWriter().print("{\"result\": \"failure\", \"reason\": \"not found\"}");
    }
	}

	protected void doPut(final HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
    String location = req.getParameter("location");
    log.info("Putting data into location " + location);

    Entity model = new Entity("Data", location);
    model.setProperty("content", new Text(req.getParameter("content")));
    datastore.put(model);

    resp.getWriter().print("{\"result\": \"success\"}");
	};
	
	@Override
	protected void doDelete(final HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
    String location = req.getParameter("location");
    log.info("Deleting data at location " + location);

    Key key = KeyFactory.createKey("Data", location);
    try {
      datastore.delete(key);
      resp.getWriter().print("{\"result\": \"success\"}");
    } catch(IllegalArgumentException e) {
      resp.getWriter().print("{\"result\": \"failure\", \"reason\": \"not found\"}");
    }
  }
}
