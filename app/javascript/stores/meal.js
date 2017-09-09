import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";

const Meal = types
  .model("Meal", {
    id: types.identifier(types.number),
    description: "",
    extras: types.maybe(types.number),
    closed: false,
    closed_at: types.maybe(types.Date),
    date: types.Date,
    reconciled: false
  })
  .views(self => ({
    get max() {
      if (self.extras === null) {
        return null;
      } else {
        return Number(self.extras) + self.form.attendeesCount;
      }
    },
    get form() {
      return getParent(self, 2);
    }
  }))
  .actions(self => ({
    toggleClosed() {
      self.closed = !self.closed;
      console.log("Closed toggled.");
      return self.closed;
    },
    resetExtras() {
      self.extras = null;
      console.log("Extras reset to null.");
      return null;
    },
    resetClosedAt() {
      self.closed_at = null;
      console.log("Closed At reset to null.");
      return null;
    },
    setClosedAt() {
      const time = new Date();
      self.closed_at = time;
      console.log("Closed At updated to current time.");
      return time;
    },
    setExtras(val) {
      const previousExtras = self.extras;

      // Scenario #1: empty string
      if (val === null) {
        self.extras = null;

        axios({
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${self.id}/max`,
          method: "patch",
          data: {
            max: null,
            socket_id: window.socketId
          },
          withCredentials: true
        })
          .then(function(response) {
            if (response.status === 200) {
              console.log("Patch Extras - Success!", response.data);
            }

            return null; // return new value of extras as feedback when running function from console
          })
          .catch(function(error) {
            console.log("Patch Extras - Fail!");
            self.extras = previousExtras;

            if (error.response) {
              // The request was made and the server responded with a status code
              // that falls out of the range of 2xx
              const data = error.response.data;
              const status = error.response.status;
              const headers = error.response.headers;

              window.alert(data.message);
            } else if (error.request) {
              // The request was made but no response was received
              // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
              // http.ClientRequest in node.js
              const request = error.request;
            } else {
              // Something happened in setting up the request that triggered an Error
              const message = error.message;
            }
            const config = error.config;

            return previousExtras; // return old value of extras as feedback when running function from console
          });
      }

      // Scenario #2: positive integer
      const num = parseInt(Number(val));
      if (Number.isInteger(num) && num >= 0) {
        self.extras = num;

        axios({
          method: "patch",
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${self.id}/max`,
          data: {
            max: self.max,
            socket_id: window.socketId
          },
          withCredentials: true
        })
          .then(function(response) {
            if (response.status === 200) {
              console.log("Patch Extras - Success!", response.data);
            }

            return num; // return new value of extras as feedback when running function from console
          })
          .catch(function(error) {
            console.log("Patch Extras - Fail!");
            self.extras = previousExtras;

            if (error.response) {
              // The request was made and the server responded with a status code
              // that falls out of the range of 2xx
              const data = error.response.data;
              const status = error.response.status;
              const headers = error.response.headers;

              window.alert(data.message);
            } else if (error.request) {
              // The request was made but no response was received
              // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
              // http.ClientRequest in node.js
              const request = error.request;
            } else {
              // Something happened in setting up the request that triggered an Error
              const message = error.message;
            }
            const config = error.config;

            return previousExtras; // return old value of extras as feedback when running function from console
          });
      }
    },
    incrementExtras() {
      if (self.extras === null) {
        return;
      }

      const num = parseInt(Number(self.extras));
      if (Number.isInteger(num)) {
        const temp = num + 1;
        self.extras = temp;
      }
    },
    decrementExtras() {
      if (self.extras === null) {
        return;
      }

      const num = parseInt(Number(self.extras));
      if (Number.isInteger(num)) {
        const temp = num - 1;
        self.extras = temp;
      }
    }
  }));

export default Meal;
