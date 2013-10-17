$(document).ready ->
  $('#reporting_tabs').tabs()

  $(document).on "change", ".reporting_field", ->
    window.check_deps()
    if $(this).data("resolve") and $(this).val() != ""
      res = $(this).data("resolve")
      $(res).prop('disabled', false)
      cattype = $(this).val()
      optionswitch(cattype, res)

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
    if options[i - 1] == myfilterclass
      optionlisting = optionlisting + '<option value="' + options[i - 2] + '" class="sub-' + options[i - 1] + '">' + options[i] + '</option>'
      resultgood = true
  if resultgood
    return optionlisting

window.create_date_pickers = ->
  $("#date_range_from").datepicker
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd",
    numberOfMonths: 3,
    onClose: (selectedDate) ->
      unless selectedDate == ""
        $("#date_range_to").datepicker( "option", "minDate", selectedDate )

  $("#date_range_to").datepicker
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd",
    numberOfMonths: 3,
    onClose: (selectedDate) ->
      unless selectedDate == ""
        $("#date_range_from").datepicker( "option", "maxDate", selectedDate )
  
  minDate = $("#date_range_from").data("from") 
  maxDate = $("#date_range_to").data("to") 

  console.log minDate, maxDate

  if minDate
    $("#date_range_from").datepicker("option", "minDate", new Date(minDate))
    $("#date_range_to").datepicker("option", "minDate", new Date(minDate))
  
  if maxDate
    $("#date_range_from").datepicker("option", "maxDate", new Date(maxDate))
    $("#date_range_to").datepicker("option", "maxDate", new Date(maxDate))

  
window.check_deps = ->
  $(".check_dep_class").each ->
    dep = $(this).data("dependency")
    if $(dep).val() == ""
      $(this).val("")
      $(dep).data("resolve", "#" + $(this).attr('id'))
      $(this).prop('disabled', true)

