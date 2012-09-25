loadDescription = (url) ->
  $.ajax
    type: 'POST'
    url: url

addService = (id) ->
  $.ajax
    type: 'POST'
    url: "/service_requests/#{id}/add_service"

removeService = (id) ->
  $.ajax
    type: 'POST'
    url: "/service_requests/#{id}/remove_service"

$(document).ready ->
  $('#institution_accordion').accordion
    autoHeight: false
    collapsible: true
    change: (event, ui)->
      if url = (ui.newHeader.find('a').attr('href') or ui.oldHeader.find('a').attr('href'))
        loadDescription(url)

  $('.provider_accordion').accordion
    autoHeight: false
    collapsible: true
    change: (event, ui)->
      if url = (ui.newHeader.find('a').attr('href') or ui.oldHeader.find('a').attr('href'))
        loadDescription(url)
  

  $('.title .name a').live 'click', ->
    $(this).parents('.title').siblings('.service-description').toggle()

  $('.add_service').live 'click', ->
    id = $(this).attr('id')
    addService(id)

  $('.remove-button').live 'click', ->
    $(this).hide()
    id = $(this).attr('id')
    removeService(id)

  helpList = "<ul>
                <li>
                  <span onclick=\"$('#help_answer_0').toggle();\" class=\"help_question\">
                    May I submit a request for services for multiple research 
                    studies/projects simultaneously?
                  </span> 
                  <span id=\"help_answer_0\" style=\"display: none;\" class=\"help_answer\">
                    No. Please browse and select services for only one research study/project at a time.
                  </span>
                </li>
                <li>
                  <span onclick=\"$('#help_answer_1').toggle();\" class=\"help_question\">
                    May I select and add services from multiple Service Providers and Programs at one time?
                  </span> 
                  <span id=\"help_answer_1\" style=\"display: none;\" class=\"help_answer\">
                    Yes. Please feel free to browse, select, and add services from any Service Provider,
                    Program, and/or Core displayed in the system for any given research study/project.
                  </span>
                </li>
                <li>
                  <span onclick=\"$('#help_answer_2').toggle();\" class=\"help_question\">
                    How many Authorized Users can I add?
                  </span> 
                  <span id=\"help_answer_2\" style=\"\" class=\"help_answer\">
                    Add as many Authorized Users as you feel is pertinent. There is no limit.
                  </span>
                </li>
                <li>
                  <span onclick=\"$('#help_answer_3').toggle();\" class=\"help_question\">
                    What is the difference  between a Research Study and a Research Project?
                  </span> 
                  <span id=\"help_answer_3\" style=\"display:none;\" class=\"help_answer\">
                    A Research Study is an individual research protocol with defined aims and outcomes.
                  </span>
                </li>
                <li>
                  <span onclick=\"$('#help_answer_4').toggle();\" class=\"help_question\">
                    How is SPARC calculating my indirect costs?
                  </span> 
                  <span id=\"help_answer_4\" style=\"display:none;\" class=\"help_answer\">
                    The original requester for your study/project defined both the funding source of the          
                    study/project and the indirect cost rate. SPARC uses this data to calculate your total          
                    overall indirect costs.
                  </span>
                </li>
                <li>
                  <span onclick=\"$('#help_answer_5').toggle();\" class=\"help_question\">
                    I’m stuck! Who can I contact for assistance with SPARC?
                  </span> 
                  <span id=\"help_answer_5\" style=\"display:none;\" class=\"help_answer\">
                    The SUCCESS Center is happy to assist you! Please contact us at <a href=\"mailto:success@musc.edu\">success@musc.edu</a>          
                    or (843) 792-3357.
                  </span>
                </li>
              </ul>"

  $('#cart-help').qtip
    content:
      text: helpList 
      title:
        text: "Help"
        button: "X"

    position:
      corner:
        target: "topRight"
        tooltip: "bottomLeft"

      adjust: screen: true

    show:
      when: "click"
      solo: true

    hide: false
    style:
      tip: true
      border:
        width: 0
        radius: 4

      name: "light"
      width: 250

