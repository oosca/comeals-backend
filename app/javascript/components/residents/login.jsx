import React from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";
import Cookie from "js-cookie";

class ResidentsLogin extends React.Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    axios
      .post(
        `${window.host}api.comeals${window.topLevel}/api/v1/residents/token`,
        {
          email: values.email,
          password: values.password
        }
      )
      .then(function(response) {
        if (response.status === 200) {
          console.log("data", response.data);
          Cookie.set("token", response.data.token, {
            expires: 7300,
            domain: `.comeals${window.topLevel}`
          });
          window.location.href = `${window.host}${response.data
            .slug}.comeals${window.topLevel}/calendar`;
        }
      })
      .catch(function(error) {
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
      });
  }

  render() {
    return (
      <div>
        <LocalForm
          onUpdate={form => this.handleUpdate(form)}
          onChange={values => this.handleChange(values)}
          onSubmit={values => this.handleSubmit(values)}
        >
          <fieldset className="width-50">
            <legend>Resident Login</legend>
            <label className="width-75">
              <Control.text
                model=".email"
                placeholder="Email"
                autoCapitalize="none"
              />
            </label>
            <br />
            <label className="width-75">
              <Control
                type="password"
                model=".password"
                placeholder="Password"
              />
            </label>
          </fieldset>

          <button type="submit">Submit</button>
        </LocalForm>
        <br />
        <a href="/residents/password-reset">Forgot you password?</a>
      </div>
    );
  }
}

export default ResidentsLogin;
