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
      '#study_type_answer_higher_level_of_privacy_answer':
        'true'             : ['#study_type_answer_certificate_of_conf']
      '#study_type_answer_certificate_of_conf_answer':
        'false'            : ['#study_type_answer_access_study_info']
      '#study_type_answer_access_study_info_answer':
        'false'            : ['#study_type_answer_epic_inbasket', '#study_type_answer_research_active', '#study_type_answer_restrict_sending']

    ready: ->
      FormFxManager.registerListeners($('.user-edit-protocol-view'), Sparc.study.display_dependencies)

      ####### If send to epic is selected we need to do some crazy stuff,  using FormFxManager for some of it but it couldn't handle the complexity, using a combination, see below ########

      $('#study_selected_for_epic_true').click ->
        $('.study_type').show()
      $('#study_selected_for_epic_false').click ->
        $('.study_type').hide()
        $('.study_type select').val("").change()

      $("#study_type_answer_higher_level_of_privacy_answer").change ->
        if $(this).val() != 'false'
          for elem in ['#study_type_answer_epic_inbasket', '#study_type_answer_research_active', '#study_type_answer_restrict_sending']
            $(elem).hide()

          for elem in ['#study_type_answer_epic_inbasket_answer', '#study_type_answer_research_active_answer', '#study_type_answer_restrict_sending_answer']
            $(elem).val("").change()

        if $(this).val() != 'true'
          $("#study_type_answer_certificate_of_conf_answer").val("").change()
          $("#study_type_answer_access_study_info_answer").val("").change()

        if $(this).val() == 'false'
          for elem in ['#study_type_answer_epic_inbasket', '#study_type_answer_research_active', '#study_type_answer_restrict_sending']
            $(elem).show()

      $("#study_type_answer_certificate_of_conf_answer").change ->
        if $(this).val() == 'true'
          $("#study_type_answer_access_study_info_answer").val("").change()
          $("#study_type_answer_epic_inbasket_answer").val("").change()
          $("#study_type_answer_research_active_answer").val("").change()
          $("#study_type_answer_restrict_sending_answer").val("").change()

      $("#study_type_answer_access_study_info_answer").change ->
        if $(this).val() == 'true'
          $("#study_type_answer_epic_inbasket_answer").val("").change()
          $("#study_type_answer_research_active_answer").val("").change()
          $("#study_type_answer_restrict_sending_answer").val("").change()

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
