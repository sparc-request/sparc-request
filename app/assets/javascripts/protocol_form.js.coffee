# Copyright © 2011-2018 MUSC Foundation for Research Development
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

(exports ? this).updateRmidFields = () ->
  rmId = $('.research-master-field').val()
  if rmId
    $.ajax
      url: "#{gon.rm_id_api_url}research_masters/#{rmId}.json"
      type: 'GET'
      headers: {"Authorization": "Token token=\"#{gon.rm_id_api_token}\""}
      success: (data) ->
        $('#protocol_short_title').val(data.short_title)
        $('#protocol_title').val(data.long_title)
        if data.eirb_validated
          $('#protocol_human_subjects_info_attributes_pro_number').val(data.eirb_pro_number)
          $('#protocol_human_subjects_info_attributes_initial_irb_approval_date').val(data.date_initially_approved)
          $('#protocol_human_subjects_info_attributes_irb_approval_date').val(data.date_approved)
          $('#protocol_human_subjects_info_attributes_irb_expiration_date').val(data.date_expiration)
          toggleFields('.rm-locked-fields', true)
        else
          toggleFields('.rm-locked-fields:not(.hr-field)', true)
      error: ->
        swal("Error", "Research Master Record not found", "error")
        resetRmIdFields('.rm-id-dependent', '')
        toggleFields('.rm-locked-fields', false)

toggleFields = (fields, state) ->
  $(fields).prop('disabled', state)

resetRmIdFields = (fields, value) ->
  $(fields).val(value)

study_type_form = '.selected_for_epic_dependent'
study_selected_for_epic_button = '#selected_for_epic_button'
certificate_of_confidence_dropdown = '#study_type_answer_certificate_of_conf_answer'
higher_level_of_privacy_dropdown = '#study_type_answer_higher_level_of_privacy_answer'
epic_inbasket_dropdown = '#study_type_answer_epic_inbasket_answer'
research_active_dropdown = '#study_type_answer_research_active_answer'
restrict_sending_dropdown = '#study_type_answer_restrict_sending_answer'
certificate_of_confidence_no_epic = '#study_type_answer_certificate_of_conf_no_epic_answer'
higher_level_of_privacy_no_epic = '#study_type_answer_higher_level_of_privacy_no_epic_answer'

$(document).ready ->

  # Guarantor Fields required toggle, removed for now.

  # if $('#protocol_selected_for_epic').val() == "true"
  #   $('.guarantor_toggle').addClass('required')

  # $(document).on 'click', '#study_selected_for_epic_true_button', ->
  #   $('.guarantor_toggle').addClass('required')

  # $(document).on 'click', '#study_selected_for_epic_false_button', ->
  #   $('.guarantor_toggle').removeClass('required')

  # Human Subjects required toggles

  if $('.human-subjects:checkbox:checked').length > 0
    $('.rm-id').addClass('required')

  $(document).on 'click', '.human-subjects', ->
    if $('.rm-id').hasClass('required')
      $('.rm-id').removeClass('required')
    else
      $('.rm-id').addClass('required')

  updateRmidFields()

  $(document).on 'blur', '.research-master-field', ->
    updateRmidFields()

  $(document).on 'change', '.research-master-field', ->
    if $(this).val() == ''
      resetRmIdFields('.rm-id-dependent', '')
      toggleFields('.rm-locked-fields', false)

  $(document).on 'click', '.edit-rmid', ->
    $('#protocol_research_master_id').prop('readonly', false)

  $('#protocol-form-display form').bind 'submit', ->
    $(this).find(':input').prop('disabled', false)

  # Protocol Edit Begin
  $(document).on 'click', '#protocol-type-button', ->
    protocol_id = $(this).data('protocol-id')
    srid        = $(this).data('srid')
    in_dashboard = if $(this).data('in-dashboard') == 1 then '/dashboard' else ''
    data =
      type : $("#protocol_type").val()
      srid : srid
    if confirm(I18n['protocols']['change_type']['warning'])
      $.ajax
        type: 'PUT'
        url: "#{in_dashboard}/protocols/#{protocol_id}/update_protocol_type"
        data: data
  # Protocol Edit End

  epic_box_alert_message = () ->
    options = {
      resizable: false,
      height: 220,
      modal: true,
      autoOpen: false,
      buttons:
        "OK": ->
          $(this).dialog("close")
    }
    $('#epic_box_alert').dialog(options).dialog("open")

  #########################
  ### FORM FIELDS LOGIC ###
  #######################################################################################
  ### INITIAL PAGE LOAD EDIT STUDY IN SPARCRequest #######################
  setup_epic_question_config()

  ###FUNDING STATUS FIELDS DISPLAY###
  $(document).on 'change', '#protocol_funding_status', ->
    $('.funding_status_dependent').hide()
    status_value = $(this).val()
    source_value = ''

    if status_value == 'funded'
      $('.funded').show()
      source_value = $('#protocol_funding_source').val()
    else if status_value == 'pending_funding'
      $('.pending_funding').show()
      source_value = $('#protocol_potential_funding_source').val()

    if source_value == 'federal'
      $(".federal").show()
    else
      $(".federal").hide()
  ###END FUNDING STATUS FIELDS DISPLAY###

  

  ###FUNDING SOURCE FIELDS DISPLAY###
  $(document).on 'change', '#protocol_potential_funding_source', ->
    if $(this).val() == 'federal'
      $('.federal').show()
    else
      $('.federal').hide()

  $(document).on 'change', '#protocol_funding_source', ->
    $('.funding_source_dependent').hide()
    switch $(this).val()
      when 'federal' then $('.federal').show()
      when 'internal' then $('.internal').show()
  ###END FUNDING SOURCE FIELDS DISPLAY###



  ###HUMAN SUBJECTS FIELDS DISPLAY###
  $(document).on 'change', '#protocol_research_types_info_attributes_human_subjects', ->
    switch $(this).attr('checked')
      when 'checked' then $('.human_subjects_dependent').show()
      else $('.human_subjects_dependent').hide()
  ###END HUMAN SUBJECTS FIELDS DISPLAY###



  ###VERTEBRATE ANIMALS FIELDS DISPLAY###
  $(document).on 'change', '#protocol_research_types_info_attributes_vertebrate_animals', ->
    switch $(this).attr('checked')
      when 'checked' then $('.vertebrate_animals_dependent').show()
      else $('.vertebrate_animals_dependent').hide()
  ###END VERTEBRATE ANIMALS FIELDS DISPLAY###



  ###INVESTIGATIONAL PRODUCTS FIELDS DISPLAY###
  $(document).on 'change', '#protocol_research_types_info_attributes_investigational_products', ->
    switch $(this).attr('checked')
      when 'checked' then $('.investigational_products_dependent').show()
      else $('.investigational_products_dependent').hide()

  $(document).on 'change', '#protocol_investigational_products_info_attributes_ind_number', ->
    if !!$(this).val().replace(/^\s+/g, "")
      $('#ind-on-hold-group').show()
    else
      $('#ind-on-hold-group').hide()
      $('#protocol_investigational_products_info_attributes_ind_on_hold').attr('checked', false)

  $(document).on 'change', 'input[name="protocol[investigational_products_info_attributes][exemption_type]"]', ->
    $('.inv-device-number-field').appendTo($(this).closest('.row'))
    $('#protocol_investigational_products_info_attributes_inv_device_number').removeClass('hidden')

  $(document).on 'click', '.clear-inv-device-number-button', (event) ->
    # prevent form submit?
    event.preventDefault()
    $('#protocol_investigational_products_info_attributes_exemption_type_').prop('checked', true)
    $('#protocol_investigational_products_info_attributes_inv_device_number').addClass('hidden').val('')
  ###END INVESTIGATIONAL PRODUCTS FIELDS DISPLAY###



  ###IP/PATENTS FIELDS DISPLAY###
  $(document).on 'change', '#protocol_research_types_info_attributes_ip_patents', ->
    switch $(this).attr('checked')
      when 'checked' then $('.ip_patents_dependent').show()
      else $('.ip_patents_dependent').hide()
  ###END IP/PATENTS FIELDS DISPLAY###



  ###IMPACT AREAS OTHER FIELD DISPLAY###
  $(document).on 'change', '#protocol_impact_areas_attributes_7__destroy', ->
    # Impact Areas Other - Checkbox
    switch $(this).attr('checked')
      when 'checked' then $('.impact_area_dependent').show()
      else $('.impact_area_dependent').hide()
  ###END IMPACT AREAS OTHER FIELD DISPLAY###



  ###########################################
  ### Primary PI TypeAhead Input Handling ###
  #######################################################################################
  if $('#protocol_project_roles_attributes_0_identity_id[type="text"]').length > 0
    identities_bloodhound = new Bloodhound(
      datumTokenizer: (datum) ->
        Bloodhound.tokenizers.whitespace datum.value
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: '/dashboard/associated_users/search_identities?term=%QUERY',
        wildcard: '%QUERY'
    )
    identities_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
    $('#protocol_project_roles_attributes_0_identity_id[type="text"]').typeahead(
      # Instantiate the Typeahead UI
      {
        minLength: 3
        hint: false
        highlight: true
      }
      {
        displayKey: 'label'
        source: identities_bloodhound.ttAdapter()
        limit: 100000
      }
    )
    .on 'typeahead:select', (event, suggestion) ->
      $("#protocol_project_roles_attributes_0_identity_id[type='hidden']").val(suggestion.value)
      $("#protocol_project_roles_attributes_0_identity_id[type='text']").hide()
      $("#primary_pi_name").text("#{suggestion.label}").removeClass('hidden')
      $("#user-select-clear-icon").show()

    $('#user-select-clear-icon').live 'click', ->
      $("#primary_pi_name").text("").addClass('hidden')
      $('#user-select-clear-icon').hide()
      $("#protocol_project_roles_attributes_0_identity_id[type='hidden']").val('')
      $("#protocol_project_roles_attributes_0_identity_id[type='text']").val('').show()

$.prototype.hide_elt = () ->
    this[0].selectedIndex = 0
    this.selectpicker('refresh')
    this.closest('.row').hide()
    return this

$.prototype.show_elt = () ->
  this.closest('.row').show()
  return this

determine_study_type = (answers) ->
  array_values = new Array()
  for k,v of answers
    array_values.push(v)
  nil_value = $.inArray('', array_values) < 5
  if array_values[0] == 'true' || !nil_value
    $.ajax
      type: 'POST'
      data: answers
      url: "/study_type/determine_study_type_note"
      success: ->
        $('#study_type_note').show()
      errors: ->
        sweetAlert("Oops...", "Something went wrong!", "error")

(exports ? this).setup_epic_question_config = () ->
  if $('#study_selected_for_epic_true_button').hasClass('active')
    $(study_type_form).show()
    $(certificate_of_confidence_dropdown).show_elt()
    $('#study_type_answer_certificate_of_conf_answer').show_elt()
    $('#study_type_note').show()

  else if $('#study_selected_for_epic_false_button').hasClass('active') || $('input#epic_config').val() == 'false'
    $(study_type_form).show()
    $(certificate_of_confidence_no_epic).show_elt()

  ###PUBLISH IN EPIC BUTTON STATES###
  $(document).on 'click', '#selected_for_epic_button label', ->
    $(this).addClass('active')
    $(this).children('input').prop('checked')
    $(this).siblings('.active').removeClass('active')

  ###END PUBLISH IN EPIC BUTTON STATES###

  if $("input[name='protocol[selected_for_epic]'][val='true']").prop('checked')
    $(study_type_form).show()
    $(certificate_of_confidence_dropdown).show_elt()

  ###EPIC BUTTON FIELDS DISPLAY###
  $(document).on 'change', "input[name='protocol[selected_for_epic]']", ->
    # Publish Study in Epic - Radio
    switch $('#selected_for_epic_button .btn input:radio:checked').val()
      when 'true'
        $('.question-label').addClass('required')
        $(certificate_of_confidence_no_epic).hide_elt().trigger 'change'
        $(certificate_of_confidence_dropdown).show_elt()
      when 'false'
        $('.question-label').removeClass('required')
        $(certificate_of_confidence_dropdown).hide_elt().trigger 'change'
        $(certificate_of_confidence_no_epic).show_elt()
    $(study_type_form).hide()
    $(study_type_form).show()


  $(document).on 'change', certificate_of_confidence_dropdown, (e) ->
    new_value = $(e.target).val()
    if new_value == 'false'
      $(higher_level_of_privacy_dropdown).show_elt()
      $('#study_type_note').hide()
    else if new_value == 'true'
      $(higher_level_of_privacy_dropdown).hide_elt()
      $(epic_inbasket_dropdown).hide_elt()
      $(research_active_dropdown).hide_elt()
      $(restrict_sending_dropdown).hide_elt()
      data = { ans1: $(certificate_of_confidence_dropdown).val(), ans2: $(higher_level_of_privacy_dropdown).val(), ans3: $(epic_inbasket_dropdown).val(), ans4: $(research_active_dropdown).val(), ans5: $(restrict_sending_dropdown).val(), ans6: "", ans7: ""  }
      determine_study_type(data)
    else
      $(higher_level_of_privacy_dropdown).hide_elt()
      $(epic_inbasket_dropdown).hide_elt()
      $(research_active_dropdown).hide_elt()
      $(restrict_sending_dropdown).hide_elt()
      $('#study_type_note').hide()
    return

  $(document).on 'change', higher_level_of_privacy_dropdown, (e) ->
    if $(e.target).val() == ''
      $(epic_inbasket_dropdown).hide_elt()
      $(research_active_dropdown).hide_elt()
      $(restrict_sending_dropdown).hide_elt()
      $('#study_type_note').hide()
    else
      data = { ans1: $(certificate_of_confidence_dropdown).val(), ans2: $(higher_level_of_privacy_dropdown).val(), ans3: $(epic_inbasket_dropdown).val(), ans4: $(research_active_dropdown).val(), ans5: $(restrict_sending_dropdown).val(), ans6: "", ans7: ""  }
      determine_study_type(data)
      if $('#selected_for_epic_button .btn input:radio:checked').val() == 'true'
        $(epic_inbasket_dropdown).show_elt()
    return

  $(document).on 'change', epic_inbasket_dropdown, (e) ->
    if $(e.target).val() == ''
      $(research_active_dropdown).hide_elt()
      $(restrict_sending_dropdown).hide_elt()
      $('#study_type_note').hide()
    else
      data = { ans1: $(certificate_of_confidence_dropdown).val(), ans2: $(higher_level_of_privacy_dropdown).val(), ans3: $(epic_inbasket_dropdown).val(), ans4: $(research_active_dropdown).val(), ans5: $(restrict_sending_dropdown).val(), ans6: "", ans7: ""  }
      determine_study_type(data)
      $(research_active_dropdown).show_elt()
    return

  $(document).on 'change', research_active_dropdown, (e) ->
    if $(e.target).val() == ''
      $(restrict_sending_dropdown).hide_elt()
      $('#study_type_note').hide()
    else
      data = { ans1: $(certificate_of_confidence_dropdown).val(), ans2: $(higher_level_of_privacy_dropdown).val(), ans3: $(epic_inbasket_dropdown).val(), ans4: $(research_active_dropdown).val(), ans5: $(restrict_sending_dropdown).val(), ans6: "", ans7: ""   }
      determine_study_type(data)
      $(restrict_sending_dropdown).show_elt()
    return

  $(document).on 'change', restrict_sending_dropdown, (e) ->
    new_value = $(e.target).val()
    if new_value != ''
      data = { ans1: $(certificate_of_confidence_dropdown).val(), ans2: $(higher_level_of_privacy_dropdown).val(), ans3: $(epic_inbasket_dropdown).val(), ans4: $(research_active_dropdown).val(), ans5: $(restrict_sending_dropdown).val(), ans6: "", ans7: ""  }
      determine_study_type(data)
    else
      $('#study_type_note').hide()
    return

  $(document).on 'change', certificate_of_confidence_no_epic, (e) ->
    new_value = $(e.target).val()
    if new_value == 'false'
      $(higher_level_of_privacy_no_epic).show_elt()
    else
      $(higher_level_of_privacy_no_epic).hide_elt()
    return

  ###END EPIC BUTTON FIELDS DISPLAY###

