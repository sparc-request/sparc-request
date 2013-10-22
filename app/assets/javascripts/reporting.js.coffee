$(document).ready ->
  $('#defined_reports_step_1').dialog
    autoOpen: false
    modal: true
    width: 'auto'
    height: 'auto'

  $('#defined_report_link').click ->
    #$('#defined_reports_step_1').show()
    $('#defined_reports_step_2').hide()
    $('#defined_reports_step_1').dialog("open")

  $(document).on "click", "#reporting_return_to_list", (event) ->
    event.preventDefault()
    $('#defined_reports_step_2').hide()
    $("#report_selection").show()
    $('#defined_reports_step_1').dialog("open")

  $(document).on "change", ".reporting_field", ->
    window.check_deps()
    if $(this).data("resolve") and $(this).val() != ""
      res = $(this).data("resolve")
      $(res).prop('disabled', false)
      cattype = $(this).val()
      optionswitch(cattype, res)

  $(document).on "submit", "#reporting_form", (event) ->
    empty = $('.required_field').filter ->
      this.value == ""

    if empty.length
      event.preventDefault()
      alert "Please fill out all required fields"

optionswitch = (myfilter, res) ->
  #Populate the optionstore if the first time through
  unless $(res).data("option_store")
    $(res).data("option_store", null)
    $(res + ' option[class^="sub-"]').each ->
      optvalue = $(this).val()
      optclass = $(this).prop('class')
      opttext = $(this).text()

      optionlist = $(res).data("option_store") + "@%" + optvalue + "@%" + optclass + "@%" + opttext

      $(res).data("option_store", optionlist)
  #delete everything
  $(res + ' option[class^="sub-"]').remove()
  #put the filtered stuff back
  populateoption = rewriteoption(myfilter, res)
  $(res).html(populateoption)

rewriteoption = (myfilter, res) ->
  #rewrite only the filtered stuff back into the option
  options = $(res).data("option_store").split('@%')
  resultgood = false
  myfilterclass = "sub-" + myfilter
  optionlisting = "<option value=''>Select One</option>"
  
  #first variable is always the value, second is always the class, third is always the text
  for i in [3..options.length] by 3
    regex = new RegExp(myfilterclass + '$')
    if regex.test(options[i - 1]) #~= myfilterclass
      optionlisting = optionlisting + '<option value="' + options[i - 2] + '" class="' + options[i - 1] + '">' + options[i] + '</option>'
      resultgood = true
  if resultgood
    return optionlisting

window.create_date_pickers = (from, to) ->
  $("#{from}").datepicker
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd",
    numberOfMonths: 3,
    onClose: (selectedDate) ->
      unless selectedDate == ""
        $("#{to}").datepicker( "option", "minDate", selectedDate )

  $("#{to}").datepicker
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd",
    numberOfMonths: 3,
    onClose: (selectedDate) ->
      unless selectedDate == ""
        $("#{from}").datepicker( "option", "maxDate", selectedDate )
  
  minDate = $("#{from}").data("from")
  maxDate = $("#{to}").data("to")

  if minDate
    $("#{from}").datepicker("option", "minDate", new Date(minDate))
    $("#{to}").datepicker("option", "minDate", new Date(minDate))
  
  if maxDate
    $("#{from}").datepicker("option", "maxDate", new Date(maxDate))
    $("#{to}").datepicker("option", "maxDate", new Date(maxDate))

  
window.check_deps = ->
  $(".check_dep_class").each ->
    dep = $(this).data("dependency")
    if $(dep).val() == ""
      $(this).val("")
      $(dep).data("resolve", "#" + $(this).attr('id'))
      $(this).prop('disabled', true)

