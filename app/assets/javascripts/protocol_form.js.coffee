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

$(document).on 'turbolinks:load', ->
  
  $('body').scrollspy({ target: '#protocolNavigation' })

  rmidTimer = null

  $(document).on('keyup', '#protocol_research_master_id:not([readonly=readonly])', ->
    clearTimeout(rmidTimer)
    if rmid = $(this).val()
      rmidTimer = setTimeout( (->
        $.ajax
          method: 'get'
          dataType: 'json'
          url: "#{gon.rmid_api_url}research_masters/#{rmid}"
          headers: 
            Authorization: "Token token=\"#{gon.rmid_api_token}\""
          success: (data) ->
            $('#protocol_short_title').val(data.short_title).prop('readonly', true)
            $('#protocol_title').val(data.long_title).prop('readonly', true)

            if data.eirb_validated
              $('#protocol_human_subjects_info_attributes_pro_number').val(data.eirb_pro_number).prop('readonly', true)
              $('#protocol_human_subjects_info_attributes_initial_irb_approval_date').val(data.date_initially_approved).prop('readonly', true)
              $('#protocol_human_subjects_info_attributes_irb_approval_date').val(data.date_approved).prop('readonly', true)
              $('#protocol_human_subjects_info_attributes_irb_expiration_date').val(data.date_expiration).prop('readonly', true)
          error: ->
            AlertSwal.fire(
              type: 'error',
              title: I18n.t('protocols.form.information.rmid.error.title'),
              html: I18n.t('protocols.form.information.rmid.error.text', rmid: rmid)
            )
            resetRmidFields()
      ), 250)
    else
      resetRmidFields()
  ).on('keydown', '#protocol_research_master_id:not([readonly=readonly])', ->
    clearTimeout(rmidTimer)
  )

  $(document).on 'change', '#protocol_funding_status', ->
    toggleFundingSource($(this).val())

  $(document).on 'change', '#protocol_funding_source, #protocol_potential_funding_source', ->
    toggleFederalFields($(this).val())
    toggleFundingSourceOther($(this).val())

    if $(this).val() == ''
      $('#protocol_funding_start_date, #protocol_potential_funding_start_date').prop('readonly', true).datetimepicker('clear')
    else
      $('#protocol_funding_start_date, #protocol_potential_funding_start_date').prop('readonly', false)

  $(document).on 'change', '#protocol_federal_phs_sponsor', ->
    if $('#protocol_federal_non_phs_sponsor').val()
      $('#protocol_federal_non_phs_sponsor').selectpicker('val', '')

  $(document).on 'change', '#protocol_federal_non_phs_sponsor', ->
    if $('#protocol_federal_phs_sponsor').val()
      $('#protocol_federal_phs_sponsor').selectpicker('val', '')

  $(document).on 'change', '.research-type-category', ->
    target = $(this).data('target')

    if $(this).prop('checked')
      $(target).removeClass('d-none')
    else
      $(target).addClass('d-none')

  $(document).on 'keyup', '#protocol_investigational_products_info_attributes_ind_number', ->
    if $(this).val().length > 0
      $('#protocol_investigational_products_info_attributes_ind_on_hold').attr('disabled', false).parents('.toggle').attr('disabled', false)
    else
      $('#protocol_investigational_products_info_attributes_ind_on_hold').bootstrapToggle('off')
      $('#protocol_investigational_products_info_attributes_ind_on_hold').attr('disabled', true).parents('.toggle').attr('disabled', true)

  $(document).on 'change', '#protocol_investigational_products_info_attributes_exemption_type', ->
    exemption = $(this).val()

    $('.device-container').addClass('d-none')
    $('.device-container input').val('').attr('disabled', true)
    $(".device-container##{exemption}DeviceContainer").removeClass('d-none').children('input').attr('disabled', false)

  ############################
  ### Primary PI Typeahead ###
  ############################

  identitiesBloodhound = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/search/identities?term=%TERM',
      wildcard: '%TERM'
  )
  identitiesBloodhound.initialize() # Initialize the Bloodhound suggestion engine
  $('#primary_pi_search:not([readonly=readonly])').typeahead(
    {
      minLength: 3
      hint: false
      highlight: true
    }, {
      displayKey: 'label'
      source: identitiesBloodhound.ttAdapter()
      limit: 100000,
      templates: {
        notFound: "<div class='tt-suggestion'>#{I18n.t('constants.search.no_results')}</div>",
        pending: "<div class='tt-suggestion'>#{I18n.t('constants.search.loading')}</div>"
      }
    }
  ).on 'typeahead:select', (event, suggestion) ->
    $('#protocol_primary_pi_role_attributes_identity_id').val(suggestion.value)
    $('#primary_pi_search').prop('placeholder', suggestion.label)

  ##################################
  ### Study Type Questions Logic ###
  ##################################

  $(document).on 'change', '[name="protocol[selected_for_epic]"]', ->
    if $('#studyTypeQuestionsContainer').hasClass('d-none') 
      $('#studyTypeQuestionsContainer').removeClass('d-none')

    if $(this).val() == 'true'
      $('label[for=protocol_study_type_questions]').addClass('required')
      setRequiredFields()
      hideStudyTypeQuestion($(certificateOfConfidenceNoEpic))
      showStudyTypeQuestion($(certificateOfConfidence))
    else
      $('label[for=protocol_study_type_questions]').removeClass('required')
      setRequiredFields()
      hideStudyTypeQuestion($(certificateOfConfidence))
      showStudyTypeQuestion($(certificateOfConfidenceNoEpic))

  $(document).on 'change', certificateOfConfidence, (e) ->
    if $(this).val() == 'true'
      hideStudyTypeQuestion($(higherLevelOfPrivacy))
      determineStudyType()
    else if $(this).val() == 'false'
      showStudyTypeQuestion($(higherLevelOfPrivacy))
      $('#studyTypeNote').hide()
    else
      hideStudyTypeQuestion($(higherLevelOfPrivacy))
      $('#studyTypeNote').hide()

  $(document).on 'change', higherLevelOfPrivacy, (e) ->
    if $(this).val() == ''
      hideStudyTypeQuestion($(epicInBasket))
      $('#studyTypeNote').hide()
    else
      if $('[name="protocol[selected_for_epic]"]:checked').val() == 'true'
        showStudyTypeQuestion($(epicInBasket))
      determineStudyType()

  $(document).on 'change', epicInBasket, (e) ->
    if $(this).val() == ''
      hideStudyTypeQuestion($(researchActive))
      $('#studyTypeNote').hide()
    else
      showStudyTypeQuestion($(researchActive))
      determineStudyType()

  $(document).on 'change', researchActive, (e) ->
    if $(this).val() == ''
      hideStudyTypeQuestion($(restrictSending))
      $('#studyTypeNote').hide()
    else
      determineStudyType()
      showStudyTypeQuestion($(restrictSending))

  $(document).on 'change', restrictSending, (e) ->
    if $(this).val() == ''
      $('#studyTypeNote').hide()
    else
      determineStudyType()

  $(document).on 'change', certificateOfConfidenceNoEpic, (e) ->
    if $(this).val() == 'false'
      showStudyTypeQuestion($(higherLevelOfPrivacyNoEpic))
    else
      hideStudyTypeQuestion($(higherLevelOfPrivacyNoEpic))

############################
### Function Definitions ###
############################

resetRmidFields = () ->
  $('#protocol_short_title').val('').prop('readonly', false)
  $('#protocol_title').val('').prop('readonly', false)
  $('#protocol_human_subjects_info_attributes_pro_number').val('').prop('readonly', false)
  $('#protocol_human_subjects_info_attributes_initial_irb_approval_date').datepicker('update', '').prop('readonly', false)
  $('#protocol_human_subjects_info_attributes_irb_approval_date').datepicker('update', '').prop('readonly', false)
  $('#protocol_human_subjects_info_attributes_irb_expiration_date').datepicker('update', '').prop('readonly', false)

fundingSource             = ""
potentialFundingSource    = ""
fundingStartDate          = ""
potentialFundingStartDate = ""

toggleFundingSource = (val) ->
  if val == ''
    $('#protocol_funding_source, #protocol_potential_funding_source').attr('disabled', true).selectpicker('val', '').selectpicker('refresh')
    $('#protocol_funding_start_date, #protocol_potential_funding_start_date').prop('readonly', true).datetimepicker('clear')
  else
    $('#protocol_funding_source, #protocol_potential_funding_source').attr('disabled', false).selectpicker('refresh')

    if val == 'pending_funding'
      fundingSource     = $('#protocol_funding_source').val()
      fundingStartDate  = $('#protocol_funding_start_date').val()

      $('#fundingSourceContainer').addClass('d-none')
      $('#potentialFundingSourceContainer').removeClass('d-none')
      $('#protocol_funding_source').selectpicker('val', '')
      $('#protocol_potential_funding_source').selectpicker('val', potentialFundingSource)
      $('#fundingStartDateContainer').addClass('d-none')
      $('#potentialFundingStartDateContainer').removeClass('d-none')
      $('#protocol_funding_start_date').datetimepicker('clear')
      $('#protocol_potential_funding_start_date').val(potentialFundingStartDate)
      $('#fundingRfaContainer').removeClass('d-none')

      toggleFederalFields(potentialFundingSource)
      toggleFundingSourceOther(potentialFundingSource)
    else
      potentialFundingSource    = $('#protocol_potential_funding_source').val()
      potentialFundingStartDate = $('#protocol_potential_funding_start_date').val()

      $('#fundingSourceContainer').removeClass('d-none')
      $('#potentialFundingSourceContainer').addClass('d-none')
      $('#protocol_funding_source').selectpicker('val', fundingSource)
      $('#protocol_potential_funding_source').selectpicker('val', '')
      $('#fundingStartDateContainer').removeClass('d-none')
      $('#potentialFundingStartDateContainer').addClass('d-none')
      $('#protocol_funding_start_date').val(fundingStartDate)
      $('#protocol_potential_funding_start_date').datetimepicker('clear')
      $('#fundingRfaContainer').addClass('d-none')

      toggleFederalFields(fundingSource)
      toggleFundingSourceOther(fundingSource)


federalGrantCode          = ""
federalGrantSerialNumber  = ""
federalGrantTitle         = ""
federalGrantPhsSponsor    = ""
federalGrantNonPhsSponsor = ""

toggleFederalFields = (val) ->
  if val == 'federal'
    $('#federalGrantInformation').removeClass('d-none')
    $('#protocol_federal_grant_code_id').selectpicker('val', federalGrantCode)
    $('#protocol_federal_grant_serial_number').val(federalGrantSerialNumber)
    $('#protocol_federal_grant_title').val(federalGrantTitle)
    $('#protocol_federal_phs_sponsor').selectpicker('val', federalGrantPhsSponsor)
    $('#protocol_federal_non_phs_sponsor').selectpicker('val', federalGrantNonPhsSponsor)
  else
    federalGrantCode          = $('#protocol_federal_grant_code_id').val()
    federalGrantSerialNumber  = $('#protocol_federal_grant_serial_number').val()
    federalGrantTitle         = $('#protocol_federal_grant_title').val()
    federalGrantPhsSponsor    = $('#protocol_federal_phs_sponsor').val()
    federalGrantNonPhsSponsor = $('#protocol_federal_non_phs_sponsor').val()

    $('#federalGrantInformation').addClass('d-none')
    $('#protocol_federal_grant_code_id').selectpicker('val', '')
    $('#protocol_federal_grant_serial_number').val('')
    $('#protocol_federal_grant_title').val('')
    $('#protocol_federal_phs_sponsor').selectpicker('val', '')
    $('#protocol_federal_non_phs_sponsor').selectpicker('val', '')

fundingSourceOther = ""

toggleFundingSourceOther = (val) ->
  if val == 'internal'
    $('#fundingSourceOtherContainer').removeClass('d-none')
    $('#protocol_funding_source_other').val(fundingSourceOther)
  else
    fundingSourceOther = $('#protocol_funding_source_other').val()

    $('#fundingSourceOtherContainer').addClass('d-none')
    $('#protocol_funding_source_other').val('')

certificateOfConfidence       = '#study_type_answer_certificate_of_conf_answer'
higherLevelOfPrivacy          = '#study_type_answer_higher_level_of_privacy_answer'
epicInBasket                  = '#study_type_answer_epic_inbasket_answer'
researchActive                = '#study_type_answer_research_active_answer'
restrictSending               = '#study_type_answer_restrict_sending_answer'

certificateOfConfidenceNoEpic = '#study_type_answer_certificate_of_conf_no_epic_answer'
higherLevelOfPrivacyNoEpic    = '#study_type_answer_higher_level_of_privacy_no_epic_answer'

hideStudyTypeQuestion = ($select) ->
  $select.selectpicker('val', '')
  $select.trigger('change')
  $select.closest('.form-row').hide()

showStudyTypeQuestion = ($select) ->
  $select.trigger('change')
  $select.closest('.form-row').show()

determineStudyType = () ->
  answers = {
    ans1: $(certificateOfConfidence).val(),
    ans2: $(higherLevelOfPrivacy).val(),
    ans3: $(epicInBasket).val(),
    ans4: $(researchActive).val(),
    ans5: $(restrictSending).val(),
    ans6: "",
    ans7: ""
  }

  answersArray  = Object.values(answers)
  hasNilValue   = $.inArray('', Object.values(answersArray)) < 5

  if answersArray[0] == 'true' || !hasNilValue
    $.ajax
      method: 'get'
      dataType: 'script'
      url: "/protocol/get_study_type_note"
      data:
        answers: answers











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

  $(document).on 'click', '.edit-rmid', ->
    $('#protocol_research_master_id').prop('readonly', false)

  # Protocol Edit Begin
  $(document).on 'click', '#protocol-type-button', ->
    protocol_id = $(this).data('protocol-id')
    srid        = $(this).data('srid')
    in_dashboard = if $(this).data('in-dashboard') == 1 then '/dashboard' else ''
    data =
      type : $("#protocol_type").val()
      srid : srid
    if confirm(I18n.t('protocols.change_type.warning'))
      $.ajax
        type: 'PUT'
        url: "#{in_dashboard}/protocols/#{protocol_id}/update_protocol_type"
        data: data
  # Protocol Edit End

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

(exports ? this).setup_epic_question_config = () ->
  if $('#study_selected_for_epic_true_button').hasClass('active')
    $(study_type_form).show()
    $(certificateOfConfidence).show_elt()
    $('#study_type_answer_certificate_of_conf_answer').show_elt()
    $('#studyTypeNote').show()

  else if $('#study_selected_for_epic_false_button').hasClass('active') || $('input#epic_config').val() == 'false'
    $(study_type_form).show()
    $(certificateOfConfidenceNoEpic).show_elt()

  ###PUBLISH IN EPIC BUTTON STATES###
  $(document).on 'click', '#selected_for_epic_button label', ->
    $(this).addClass('active')
    $(this).children('input').prop('checked')
    $(this).siblings('.active').removeClass('active')

  ###END PUBLISH IN EPIC BUTTON STATES###

  if $("input[name='protocol[selected_for_epic]'][val='true']").prop('checked')
    $(study_type_form).show()
    $(certificateOfConfidence).show_elt()
