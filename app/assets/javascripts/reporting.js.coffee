# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  $(document).on "click", "#reporting-return-to-list", (event) ->
    event.preventDefault()
    $('#report-container').hide()
    $('#report-selection').show()

  $(document).on "change", ".reporting-field", ->
    parent_id = "#" + $(this).attr('id')
    if $(this).val() == "" && parent_id != '#core_id'
      disable_deps(parent_id)
    else
      parent_val = $(this).val()
      $("[data-dependency*=\"#{parent_id}\"]").each ->
        new_parent_id = "#" + $(this).attr('id')
        $(this).selectpicker("val", "")
        $(this).siblings('.bootstrap-select').children('button').prop('disabled', false)
        disable_deps(new_parent_id)
        if parent_val == "" && parent_id == '#core_id'
          cattype = $('#program_id').val()
          optionswitch(cattype, "#" + $(this).attr('id'))
        else
          cattype = $(parent_id).val()
          optionswitch(cattype, "#" + $(this).attr('id'))

  $(document).on "submit", "#reporting-form", (event) ->
    empty = $('.required').filter ->
      this.value == ""

    if empty.length
      event.preventDefault()
      alert I18n['reporting']['actions']['errors']

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
  $(res).selectpicker('refresh')

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

window.disable_deps = (parent_id) ->
  $("[data-dependency*=\"#{parent_id}\"]").each ->
    $(this).selectpicker("val", "")
    $(this).siblings('.bootstrap-select').children('button').prop('disabled', true)
    new_parent_id = "#" + $(this).attr('id')
    disable_deps(new_parent_id)
