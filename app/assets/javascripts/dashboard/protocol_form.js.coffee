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

  study_type_form = '.selected_for_epic_dependent'
  study_selected_for_epic_button = '#selected_for_epic_button'
  certificate_of_confidence_dropdown = '#study_type_answer_certificate_of_conf_answer'
  higher_level_of_privacy_dropdown = '#study_type_answer_higher_level_of_privacy_answer'
  access_required_dropdown = '#study_type_answer_access_study_info_answer'
  epic_inbasket_dropdown = '#study_type_answer_epic_inbasket_answer'
  research_active_dropdown = '#study_type_answer_research_active_answer'
  restrict_sending_dropdown = '#study_type_answer_restrict_sending_answer'

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

  $.prototype.hide_elt = () ->
    this[0].selectedIndex = 0
    this.closest('.row').hide()
    return this

  $.prototype.show_elt = () ->
    this.closest('.row').show()
    return this

  # $.prototype.hide_visual_error = () ->
  #   this.removeClass('visual_error')
  #   if $('.visual_error').length == 0
  #     $('.study_type div').removeClass('field_with_errors')
  #     if $('#errorExplanation ul li').size() == 1
  #       $('#errorExplanation').remove()
  #     else
  #       $('#errorExplanation ul li:contains("Study type questions must be selected")').remove()

  # add_and_check_visual_error_on_submit = (dropdown) ->
  #   if dropdown.is(':visible') && dropdown.val() == ''
  #     dropdown.addClass('visual_error')
  #     dropdown.on 'change', (e) ->
  #       dropdown.hide_visual_error()

  # add_and_check_visual_error_on_field_change = (dropdown) ->
  #   siblings = dropdown.parent('.row').siblings().find('.visual_error')
  #   if siblings
  #     for sibling in siblings
  #       if !$(sibling).is(':visible')
  #         $(sibling).hide_visual_error()

  # When the epic box answers hit the validations with an unselected field,
  # the html.haml sets display to none for unselected fields
  # So if the user has not filled out one of the
  # required fields in the epic box, it will hit this code and display
  # the appropriate fields that need to be filled out with a visual cue of red border
  if $('.field_with_errors label:contains("Study type questions")').length > 0
    $(study_selected_for_epic_button).change()
    if $(certificate_of_confidence_dropdown).is(':visible')
      $(certificate_of_confidence_dropdown).change()
    if $(higher_level_of_privacy_dropdown).val() == 'true'
      $(access_required_dropdown).show_elt()
      $(access_required_dropdown).change()
    if $(higher_level_of_privacy_dropdown).val() == 'false'
      $(higher_level_of_privacy_dropdown).change()
    if $(certificate_of_confidence_dropdown) != "" && $(higher_level_of_privacy_dropdown).val() != "" && $(access_required_dropdown).val() == 'false'
      $(access_required_dropdown).change()
    add_and_check_visual_error_on_submit($(certificate_of_confidence_dropdown))
    add_and_check_visual_error_on_submit($(higher_level_of_privacy_dropdown))
    add_and_check_visual_error_on_submit($(access_required_dropdown))
    add_and_check_visual_error_on_submit($(epic_inbasket_dropdown))
    add_and_check_visual_error_on_submit(research_active_dropdown)
    add_and_check_visual_error_on_submit($(restrict_sending_dropdown))

    $(certificate_of_confidence_dropdown).on 'change', (e) ->
      add_and_check_visual_error_on_field_change($(certificate_of_confidence_dropdown))

    $(higher_level_of_privacy_dropdown).on 'change', (e) ->
      add_and_check_visual_error_on_field_change($(higher_level_of_privacy_dropdown))

    $(access_required_dropdown).on 'change', (e) ->
      add_and_check_visual_error_on_field_change($(access_required_dropdown))

  #### This was written for an edge case in admin/portal.
  #### When you go from a virgin project (selected_for_epic = nil/ never been a study)
  #### to a study, the Epic Box should be editable instead of only displaying the epic box data.

  if $('#study_can_edit_admin_study').val() == "can_edit_study"
    $('#actions input[type="submit"]').on 'click', (e) ->
      if $('input[name=\'study[selected_for_epic]\']:checked').val() == 'true'
        if $(certificate_of_confidence_dropdown).val() == ''
          epic_box_alert_message()
          add_and_check_visual_error_on_submit($(certificate_of_confidence_dropdown))
          return false
        if $(certificate_of_confidence_dropdown).val() == 'false'
          if $(higher_level_of_privacy_dropdown).val() == ''
            epic_box_alert_message()
            add_and_check_visual_error_on_submit($(higher_level_of_privacy_dropdown))
            return false
          if $(higher_level_of_privacy_dropdown).val() == 'true'
            if $(access_required_dropdown).val() == ''
              epic_box_alert_message()
              add_and_check_visual_error_on_submit($(access_required_dropdown))
              return false
            if $(access_required_dropdown).val() == 'false'
              if $(epic_inbasket_dropdown).val() == '' ||$(research_active_dropdown).val() == '' || $(restrict_sending_dropdown).val() == ''
                epic_box_alert_message()
                add_and_check_visual_error_on_submit($(epic_inbasket_dropdown))
                add_and_check_visual_error_on_submit(research_active_dropdown)
                add_and_check_visual_error_on_submit($(restrict_sending_dropdown))
                return false
          else if $(higher_level_of_privacy_dropdown).val() == 'false'
            if $(epic_inbasket_dropdown).val() == '' ||$(research_active_dropdown).val() == '' || $(restrict_sending_dropdown).val() == ''
              epic_box_alert_message()
              add_and_check_visual_error_on_submit($(epic_inbasket_dropdown))
              add_and_check_visual_error_on_submit(research_active_dropdown)
              add_and_check_visual_error_on_submit($(restrict_sending_dropdown))
              return false
  ######## End of send to epic study question logic ##############

  #########################
  ### FORM FIELDS LOGIC ###
  #######################################################################################

  ###FUNDING STATUS FIELDS DISPLAY###
  $(document).on 'change', '#protocol_funding_status', ->
    $('.funding_status_dependent').hide()
    switch $(this).val()
      when 'funded' then $('.funded').show()
      when 'pending_funding' then $('.pending_funding').show()
  ###END FUNDING STATUS FIELDS DISPLAY###



  ###FUNDING SOURCE FIELDS DISPLAY###
  $(document).on 'change', '#protocol_funding_source', ->
    $('.funding_source_dependent').hide()
    switch $(this).val()
      when 'federal' then $('.federal').show()
      when 'internal' then $('.internal').show()
  ###END FUNDING SOURCE FIELDS DISPLAY###



  ###PUBLISH IN EPIC BUTTON STATES###
  $(document).on 'click', '#selected_for_epic_button label', ->
    $(this).addClass('active')
    $(this).children('input').prop('checked')
    $(this).siblings('.active').removeClass('active')

  ###END PUBLISH IN EPIC BUTTON STATES###

  if $("input[name='protocol[selected_for_epic]']").val() == 'true'
    $(study_type_form).show()
    $(certificate_of_confidence_dropdown).show_elt()

  ###EPIC BUTTON FIELDS DISPLAY###
  $(document).on 'change', "input[name='protocol[selected_for_epic]']", ->
    # Publish Study in Epic - Radio
    switch $('#selected_for_epic_button .btn input:radio:checked').val()
      when 'true'
        $(study_type_form).show()
        $(certificate_of_confidence_dropdown).show_elt()
      when 'false'
        $(study_type_form).hide()
        $(certificate_of_confidence_dropdown).hide_elt().trigger 'change'

  $(document).on 'change', certificate_of_confidence_dropdown, (e) ->
    new_value = $(e.target).val()
    if new_value == 'false'
      $(higher_level_of_privacy_dropdown).show_elt()
    else
      $(higher_level_of_privacy_dropdown).hide_elt()
      $(access_required_dropdown).hide_elt()
      $(epic_inbasket_dropdown).hide_elt()
      $(research_active_dropdown).hide_elt()
      $(restrict_sending_dropdown).hide_elt()
    return

  $(document).on 'change', higher_level_of_privacy_dropdown, (e) ->
    new_value = $(e.target).val()
    if new_value == 'false'
      $(access_required_dropdown).hide_elt()
      $(epic_inbasket_dropdown).show_elt()
      $(research_active_dropdown).show_elt()
      $(restrict_sending_dropdown).show_elt()
    else
      $(access_required_dropdown).show_elt()
      $(epic_inbasket_dropdown).hide_elt()
      $(research_active_dropdown).hide_elt()
      $(restrict_sending_dropdown).hide_elt()
    return

  $(document).on 'change', access_required_dropdown, (e) ->
    new_value = $(e.target).val()
    if new_value == 'false'
      $(epic_inbasket_dropdown).show_elt()
      $(research_active_dropdown).show_elt()
      $(restrict_sending_dropdown).show_elt()
    else
      $(epic_inbasket_dropdown).hide_elt()
      $(research_active_dropdown).hide_elt()
      $(restrict_sending_dropdown).hide_elt()
    return
  ###END EPIC BUTTON FIELDS DISPLAY###



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
  $(document).on 'change', '#protocol_impact_areas_attributes_6__destroy', ->
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
      $("#primary_pi_name").text("#{suggestion.label}").show()
      $("#user-select-clear-icon").show()

    $('#user-select-clear-icon').live 'click', ->
      $("#primary_pi_name").text("").hide()
      $('#user-select-clear-icon').hide()
      $("#protocol_project_roles_attributes_0_identity_id[type='hidden']").val('')
      $("#protocol_project_roles_attributes_0_identity_id[type='text']").val('').show()
