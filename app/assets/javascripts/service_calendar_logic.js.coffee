$(document).ready ->

  $(".visit_name").live 'mouseover', ->
    $(this).qtip
      overwrite: false
      content: "Click to rename your visits."
      position:
        corner:
          target: 'bottomLeft'
      show:
        ready: true

  $('.visit_day').live 'mouseover', ->
    $(this).qtip
      overwrite: false
      content: "Click to set the visits day. All days must be in numerical order. Ex. 1, 2, 4, 9"
      position:
        corner:
          target: 'topLeft'
          tooltip: 'bottomLeft'
      show:
        ready: true

  $('.visit_window').live 'mouseover', ->
    $(this).qtip
      overwrite: false
      content: "Click to set the window period the visit can be completed."
      position:
        corner:
          target: 'topLeft'
          tooltip: 'bottomLeft'
      show:
        ready: true

  $('#service_calendar').tabs
    show: (event, ui) -> 
      $(ui.panel).html('<div class="ui-corner-all" style = "border: 1px solid black; padding: 25px; width: 200px; margin: 30px auto; text-align: center">Loading data....<br /><img src="/assets/spinner.gif" /></div>')
    select: (event, ui) ->
      $(ui.panel).html('<div class="ui-corner-all" style = "border: 1px solid black; padding: 25px; width: 200px; margin: 30px auto; text-align: center">Loading data....<br /><img src="/assets/spinner.gif" /></div>')

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

