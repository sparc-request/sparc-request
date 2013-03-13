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

  changing_tabs_calculating_rates = ->
    arm_ids = []
    $('.arm_calendar_container').each (index, arm) ->
      if $(arm).is(':hidden') == false then arm_ids.push $(arm).data('arm_id')

    i = 0
    while i < arm_ids.length
      calculate_max_rates(arm_ids[i])
      i++

  if $('.line_item_visit_template').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_billing').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_quantity').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_pricing').is(':visible')
    changing_tabs_calculating_rates()

