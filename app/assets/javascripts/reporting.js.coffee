# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

$(document).ready ->

  $(document).on "click", "#reporting_return_to_list", (event) ->
    event.preventDefault()
    $('#defined_reports_step_2').hide()
    $("#report_selection").show()

  $(document).on "change", ".reporting_field", ->
    parent_id = "#" + $(this).attr('id')
    window.check_deps(parent_id)
    if $(this).val() != ""
      $(".check_dep_class.needs_update").each ->
        $(this).removeClass('needs_update')
        $(this).prop('disabled', false)
        cattype = $(parent_id).val()
        optionswitch(cattype, "#" + $(this).attr('id'))

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
  $("#{from}").datetimepicker(format: 'YYYY-MM-DD', allowInputToggle: true)
  $("#{to}").datetimepicker(format: 'YYYY-MM-DD', allowInputToggle: true, useCurrent: false)

  $("#{from}").on "dp.change", (e) ->
    $("#{to}").data('DateTimePicker').minDate(e.date)

  $("#{to}").on "dp.change", (e) ->
    $("#{from}").data('DateTimePicker').maxDate(e.date)

window.create_single_date_pickers = ->
  $(".datetimepicker").datetimepicker(format: 'YYYY-MM-DD', allowInputToggle: true)

window.check_deps = (parent_id) ->
  $(".check_dep_class").each ->
    dep = $(this).data("dependency")
    if dep.match(parent_id)
      $(this).addClass("needs_update")
      $(this).val("")

    if $(dep).val() == ""
      $(this).prop('disabled', true)

