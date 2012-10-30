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
    $('.line_item_visit_template').each (index, visit) ->
      calculate_max_rates($(visit).parent())
  else if $('.line_item_visit_billing').is(':visible')
    $('.line_item_visit_billing').each (index, visit) ->
      calculate_max_rates($(visit).parent())
  else if $('.line_item_visit_quantity').is(':visible')
    $('.line_item_visit_quantity').each (index, visit) ->
      calculate_max_rates($(visit).parent())
  else if $('.line_item_visit_pricing').is(':visible')
    $('.line_item_visit_pricing').each (index, visit) ->
      calculate_max_rates($(visit).parent())
