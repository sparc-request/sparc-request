$(document).ready ->
  $(document).ajaxError ->
      alert("Connection to the server has been terminated and/or failed.  Data may have been lost")
