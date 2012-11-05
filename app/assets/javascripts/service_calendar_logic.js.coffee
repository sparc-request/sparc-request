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

  if $('.line_item_visit_template').is(':visible')
    calculate_max_rates()
  else if $('.line_item_visit_billing').is(':visible')
    calculate_max_rates()
  else if $('.line_item_visit_quantity').is(':visible')
    calculate_max_rates()
  else if $('.line_item_visit_pricing').is(':visible')
    calculate_max_rates()
