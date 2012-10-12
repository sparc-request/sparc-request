$(document).ready ->
  $('.billing_type_list').qtip
    content: 'R = Research<br />T = Third Party (Patient Insurance)<br />% = % Effort'
    position:
      corner:
        target: "topRight"
        tooltip: "bottomLeft"

    style:
      tip: true
      border:
        width: 0
        radius: 4

      name: "light"
      width: 250

