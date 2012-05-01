// BEGIN CICERO-BOILERPLATE CODE
package "main"

import (
	"appengine"
	"appengine/datastore"
	"appengine/taskqueue"
	"fmt"
	"http"
	"json"
	"time"
)

import "{{ package_name }}"

type TaskInfo struct {
	State     string
	StartTime datastore.Time
	EndTime   datastore.Time
}

type Text struct {
	Content string
}

func init() {
	http.HandleFunc("/task", taskRoute)
	http.HandleFunc("/data", dataRoute)
	http.HandleFunc("/compute", computeWorker)
	http.HandleFunc("/", index)
}

func taskRoute(w http.ResponseWriter, r *http.Request) {
	c := appengine.NewContext(r)

	if r.Method == "GET" {
		keyName := r.FormValue("task_id")
		key := datastore.NewKey(c, "TaskInfo", keyName, 0, nil)
		taskInfo := new(TaskInfo)
		if err := datastore.Get(c, key, taskInfo); err == nil {
			result := map[string]string{
				"result": "success",
				"state":  taskInfo.State,
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		} else {
			result := map[string]string{
				"result": "failure",
				"state":  "not found",
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		}
	} else if r.Method == "PUT" {
		inputSource := r.FormValue("input1")
		output := r.FormValue("output")
		params := map[string][]string{
			"input1": {inputSource},
			"output": {output},
		}

		task := taskqueue.NewPOSTTask("/compute", params)
		if newTask, err := taskqueue.Add(c, task, ""); err == nil {
			result := map[string]string{
				"result":  "success",
				"task_id": newTask.Name,
				"output":  output,
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		} else {
			result := map[string]string{
				"result": "failure",
				"reason": err.String(),
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		}
	} else {
		// TODO - support deletion of tasks
		http.Error(w, "method not supported", http.StatusInternalServerError)
		return
	}
}

func dataRoute(w http.ResponseWriter, r *http.Request) {
	c := appengine.NewContext(r)

	if r.Method == "GET" {
		keyName := r.FormValue("location")

		key := datastore.NewKey(c, "Text", keyName, 0, nil)
		output := new(Text)
		if err := datastore.Get(c, key, output); err != nil {
			result := map[string]string{
				"result": "failure",
				"reason": err.String(),
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		}

		if output.Content == "" {
			result := map[string]string{
				"result": "failure",
				"reason": "key did not exist",
			}

			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		} else {
			result := map[string]string{
				"result": "success",
				"output": output.Content,
			}

			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		}
	} else if r.Method == "PUT" {
		keyName := r.FormValue("location")
		key := datastore.NewKey(c, "Text", keyName, 0, nil)
		text := Text{
			Content: r.FormValue("text"),
		}
		key, err := datastore.Put(c, key, &text)
		if err == nil {
			result := map[string]string{
				"result": "success",
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		} else {
			result := map[string]string{
				"result": "failure",
				"reason": err.String(),
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		}
	} else if r.Method == "DELETE" {
		keyName := r.FormValue("location")

		key := datastore.NewKey(c, "Text", keyName, 0, nil)
		err := datastore.Delete(c, key)

		if err == nil {
			result := map[string]string{
				"result": "success",
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		} else {
			result := map[string]string{
				"result": "failure",
				"reason": fmt.Sprintf("%s", err),
			}
			fmt.Fprintf(w, "%s", mapToJson(result))
			return
		}
	} else {
		http.Error(w, "method not supported", http.StatusInternalServerError)
		return
	}
}

func computeWorker(w http.ResponseWriter, r *http.Request) {
	c := appengine.NewContext(r)

	outputDest := r.FormValue("output")

	keyName := outputDest // TODO - this should use the task id, not the output location
	key := datastore.NewKey(c, "TaskInfo", keyName, 0, nil)

	taskInfo := TaskInfo{
		State:     "started",
		StartTime: datastore.SecondsToTime(time.Seconds()),
	}

	datastore.Put(c, key, &taskInfo)

	outputTextKeyName := outputDest
	outputTextKey := datastore.NewKey(c, "Text", outputTextKeyName, 0, nil)
	outputText := Text{
		Content: {{ package_name }}.{{ function_name }}(),
	}
	datastore.Put(c, outputTextKey, &outputText)

	datastore.Get(c, key, &taskInfo)
	taskInfo.State = "finished"
	taskInfo.EndTime = datastore.SecondsToTime(time.Seconds())
	datastore.Put(c, key, &taskInfo)
}

func index(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello, world!")
}

func mapToJson(mapToConvert map[string]string) []byte {
	jsonResult, err := json.Marshal(mapToConvert)
	if err != nil {
		fmt.Printf("json marshalling saw error: %s\n", err)
	}

	return jsonResult
}

// END CICERO-BOILERPLATE CODE
