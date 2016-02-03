# Copyright © 2011 MUSC Foundation for Research Development
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
  Sparc.study = {
    display_dependencies:
      "#study_funding_status" :
        pending_funding    : ['.pending_funding']
        funded             : ['.funded']
      "#study_potential_funding_source" :
        internal           : ['.internal_potential_funded_pilot_project']
      "#study_funding_source" :
        federal            : ['.federal']
        internal           : ['.internal_funded_pilot_project']
      '#study_research_types_info_attributes_human_subjects' :
        'true'             : ['.nct_number', '.hr_number', '.pro_number', '.irb_of_record', '.submission_type',
                              '.irb_approval_date', '.irb_expiration_date']
      '#study_research_types_info_attributes_vertebrate_animals' :
        'true'             : ['.iacuc_number', '.name_of_iacuc', '.iacuc_approval_date',
                              '.iacuc_expiration_date']
      '#study_research_types_info_attributes_investigational_products' :
        'true'             : ['.ind_number', '.ide_number']
      '#study_research_types_info_attributes_ip_patents':
        'true'             : ['.patent_number', '.inventors']
      '#study_investigational_products_info_attributes_ind_number':
        'true'             : ['.ind_on_hold']
      '#study_impact_areas_attributes_6__destroy':
        'true'             : ['.impact_other']

    ready: ->
      FormFxManager.registerListeners($('.user-edit-protocol-view'), Sparc.study.display_dependencies)


      if $('#viewing_admin').val() == "portal"

        study_type_form = $('.study_type')
        study_selected_for_epic_radio = $('input[name=\'study[selected_for_epic]\']')
        certificate_of_confidence_dropdown = $('#study_type_answer_certificate_of_conf_answer')
        higher_level_of_privacy_dropdown = $('#study_type_answer_higher_level_of_privacy_answer')
        access_required_dropdown = $('#study_type_answer_access_study_info_answer')
        epic_inbasket_dropdown = $('#study_type_answer_epic_inbasket_answer')
        research_active_dropdown = $('#study_type_answer_research_active_answer')
        restrict_sending_dropdown = $('#study_type_answer_restrict_sending_answer')

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
          this.closest('.field').hide()
          return this

        $.prototype.show_elt = () ->
          this.closest('.field').show()
          return this

        $.prototype.hide_visual_error = () ->
          this.removeClass('visual_error')
          if $('.visual_error').length == 0 
            $('.study_type div').removeClass('field_with_errors')
            if $('#errorExplanation ul li').size() == 1
              $('#errorExplanation').remove()
            else
              $('#errorExplanation ul li:contains("Study type questions must be selected")').remove()

        add_and_check_visual_error_on_submit = (dropdown) ->
          if dropdown.is(':visible') && dropdown.val() == ''
            dropdown.addClass('visual_error')
            dropdown.on 'change', (e) ->
              dropdown.hide_visual_error()

        add_and_check_visual_error_on_field_change = (dropdown) ->
          siblings = dropdown.parent('.field').siblings().find('.visual_error')
          if siblings
            for sibling in siblings
              if !$(sibling).is(':visible')
                $(sibling).hide_visual_error()

        # If study is inactive, we want to force users to fill out new epic box questions
        if $('#study_study_type_question_group_id').val() == "inactive" && $('input[name=\'study[selected_for_epic]\']:checked').val() == 'true'
          study_type_form.show()
          certificate_of_confidence_dropdown.show_elt()

        # Logic for epic info box 
        study_selected_for_epic_radio.on 'change', (e) ->
          if $('input[name=\'study[selected_for_epic]\']:checked').val() == 'true'
            study_type_form.show()
            certificate_of_confidence_dropdown.show_elt()
          else
            study_type_form.hide()
            certificate_of_confidence_dropdown.hide_elt().trigger 'change'
          return

        certificate_of_confidence_dropdown.on 'change', (e) ->
          new_value = $(e.target).val()
          if new_value == 'false'
            higher_level_of_privacy_dropdown.show_elt()
          else
            higher_level_of_privacy_dropdown.hide_elt()
            access_required_dropdown.hide_elt()
            epic_inbasket_dropdown.hide_elt()
            research_active_dropdown.hide_elt()
            restrict_sending_dropdown.hide_elt()
          return


        higher_level_of_privacy_dropdown.on 'change', (e) ->
          new_value = $(e.target).val()
          if new_value == 'false'
            access_required_dropdown.hide_elt()
            epic_inbasket_dropdown.show_elt()
            research_active_dropdown.show_elt()
            restrict_sending_dropdown.show_elt()
          else
            access_required_dropdown.show_elt()
            epic_inbasket_dropdown.hide_elt()
            research_active_dropdown.hide_elt()
            restrict_sending_dropdown.hide_elt()
          return
       
        access_required_dropdown.on 'change', (e) ->
          new_value = $(e.target).val()
          if new_value == 'false'
            epic_inbasket_dropdown.show_elt()
            research_active_dropdown.show_elt()
            restrict_sending_dropdown.show_elt()
          else
            epic_inbasket_dropdown.hide_elt()
            research_active_dropdown.hide_elt()
            restrict_sending_dropdown.hide_elt()
          return

        # When the epic box answers hit the validations with an unselected field, 
        # the html.haml sets display to none for unselected fields
        # So if the user has not filled out one of the 
        # required fields in the epic box, it will hit this code and display 
        # the appropriate fields that need to be filled out with a visual cue of red border
        if $('.field_with_errors label:contains("Study type questions")').length > 0
          study_selected_for_epic_radio.change()
          if certificate_of_confidence_dropdown.is(':visible')
            certificate_of_confidence_dropdown.change()
          if higher_level_of_privacy_dropdown.val() == 'true' 
            access_required_dropdown.show_elt()
            access_required_dropdown.change()
          if higher_level_of_privacy_dropdown.val() == 'false'
            higher_level_of_privacy_dropdown.change()
          if certificate_of_confidence_dropdown != "" && higher_level_of_privacy_dropdown.val() != "" && access_required_dropdown.val() == 'false'
            access_required_dropdown.change()
          add_and_check_visual_error_on_submit(certificate_of_confidence_dropdown)
          add_and_check_visual_error_on_submit(higher_level_of_privacy_dropdown)
          add_and_check_visual_error_on_submit(access_required_dropdown)
          add_and_check_visual_error_on_submit(epic_inbasket_dropdown)
          add_and_check_visual_error_on_submit(research_active_dropdown)
          add_and_check_visual_error_on_submit(restrict_sending_dropdown)

          certificate_of_confidence_dropdown.on 'change', (e) ->
            add_and_check_visual_error_on_field_change(certificate_of_confidence_dropdown)

          higher_level_of_privacy_dropdown.on 'change', (e) ->
            add_and_check_visual_error_on_field_change(higher_level_of_privacy_dropdown)

          access_required_dropdown.on 'change', (e) ->
            add_and_check_visual_error_on_field_change(access_required_dropdown)

        #### This was written for an edge case in admin/portal.  
        #### When you go from a virgin project (selected_for_epic = nil/ never been a study) 
        #### to a study, the Epic Box should be editable instead of only displaying the epic box data.
        
        if $('#can_edit_admin_study').val() == "can_edit_study"
          $('#actions input[type="submit"]').on 'click', (e) ->
            if $('input[name=\'study[selected_for_epic]\']:checked').val() == 'true'
              if certificate_of_confidence_dropdown.val() == ''
                epic_box_alert_message()
                add_and_check_visual_error_on_submit(certificate_of_confidence_dropdown)
                return false
              if certificate_of_confidence_dropdown.val() == 'false'
                if higher_level_of_privacy_dropdown.val() == ''
                  epic_box_alert_message()
                  add_and_check_visual_error_on_submit(higher_level_of_privacy_dropdown)
                  return false
                if higher_level_of_privacy_dropdown.val() == 'true'
                  if access_required_dropdown.val() == ''
                    epic_box_alert_message()
                    add_and_check_visual_error_on_submit(access_required_dropdown)
                    return false
                  if access_required_dropdown.val() == 'false'
                    if epic_inbasket_dropdown.val() == '' || research_active_dropdown.val() == '' || restrict_sending_dropdown.val() == ''
                      epic_box_alert_message()
                      add_and_check_visual_error_on_submit(epic_inbasket_dropdown)
                      add_and_check_visual_error_on_submit(research_active_dropdown)
                      add_and_check_visual_error_on_submit(restrict_sending_dropdown)
                      return false
                else if higher_level_of_privacy_dropdown.val() == 'false'
                  if epic_inbasket_dropdown.val() == '' || research_active_dropdown.val() == '' || restrict_sending_dropdown.val() == ''
                    epic_box_alert_message()
                    add_and_check_visual_error_on_submit(epic_inbasket_dropdown)
                    add_and_check_visual_error_on_submit(research_active_dropdown)
                    add_and_check_visual_error_on_submit(restrict_sending_dropdown)
                    return false

      ######## End of send to epic study question logic ##############

      $('#study_funding_status').change ->
        $('#study_funding_source').val("")
        $('#study_potential_funding_source').val("")
        $('#study_funding_source').change()
        $('#study_potential_funding_source').change()
        $('#study_indirect_cost_rate').val("")

      $('#study_federal_phs_sponsor').change ->
        $('#study_federal_non_phs_sponsor').val("")

      $('#study_federal_non_phs_sponsor').change ->
        $('#study_federal_phs_sponsor').val("")

      $('#study_impact_areas_attributes_6__destroy').change ->
        $('#study_impact_areas_other').val("")

      $('#study_funding_source, #study_potential_funding_source').change ->
        switch $(this).val()
          when "internal", "college" then $('#study_indirect_cost_rate').val(I18n["indirect_cost_rates"]["internal_and_college"])
          when "industry" then $('#study_indirect_cost_rate').val(I18n["indirect_cost_rates"]["industry"])
          when "foundation", "investigator" then $('#study_indirect_cost_rate').val(I18n["indirect_cost_rates"]["foundation_and_investigator"])
          when "federal" then $('#study_indirect_cost_rate').val(I18n["indirect_cost_rates"]["federal"])

      $('#study_research_types_info_attributes_investigational_products').change ->
        if !$(this).is(':checked')
          $('#study_investigational_products_info_attributes_ind_number').val('')
          $('#study_investigational_products_info_attributes_ind_number').change()
          $('#study_investigational_products_info_attributes_ind_on_hold').attr('checked', false)

      # id       - where to stick datepicker
      # altField - input element(s) that is to be updated with
      #            the selected date from the datepicker
      setupDatePicker = (id, altField) ->
        $(id).datepicker(
          changeMonth: true,
          changeYear:true,
          constrainInput: true,
          dateFormat: "m/dd/yy",
          showButtonPanel: true,
          closeText: "Clear",
          altField: altField,
          altFormat: 'yy-mm-dd',

          beforeShow: (input)->
            callback = ->
              buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
              buttonPane.find('button.ui-datepicker-current').hide()
              buttonPane.find('button.ui-datepicker-close').on 'click', ->
                $.datepicker._clearDate(input)
            setTimeout( callback, 1)
        ).addClass('date')

      setupDatePicker('#funding_start_date', '#study_funding_start_date')
      $('#funding_start_date').attr("readOnly", true)

      setupDatePicker('#potential_funding_start_date', '#study_potential_funding_start_date')
      $('#potential_funding_start_date').attr("readOnly", true)

      setupDatePicker('#irb_approval_date', '#study_human_subjects_info_attributes_irb_approval_date')
      $('#irb_approval_date').attr("readOnly", true)

      setupDatePicker('#irb_expiration_date', '#study_human_subjects_info_attributes_irb_expiration_date')
      $('#irb_expiration_date').attr("readOnly", true)

      setupDatePicker('#iacuc_approval_date', '#study_vertebrate_animals_info_attributes_iacuc_approval_date')
      $('#iacuc_approval_date').attr("readOnly", true)

      setupDatePicker('#iacuc_expiration_date', '#study_vertebrate_animals_info_attributes_iacuc_expiration_date')
      $('#iacuc_expiration_date').attr("readOnly", true)
  }

  $("form").submit ->
    unless $('#study_research_types_info_attributes_human_subjects').is(':checked')
      $('#study_human_subjects_info_attributes_nct_number').val('')
