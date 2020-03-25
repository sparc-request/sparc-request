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

  $('body').scrollspy({ target: '#protocolNavigation' })

  rmidTimer = null

  updateRmidFields()

  $(document).on('keyup', '#protocol_research_master_id:not([readonly=readonly])', ->
    clearTimeout(rmidTimer)
    if $(this).val()
      rmidTimer = setTimeout( (->
        updateRmidFields()
      ), 750)
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

  $(document).on 'change', '.research-involving', ->
    target = $(this).data('target')

    $(target).find('.is-valid, .is-invalid').removeClass('is-valid is-invalid')
    $(target).find('.form-error').remove()

    if $(this).prop('checked')
      $(target).removeClass('d-none')
    else
      $(target).addClass('d-none')

  $(document).on 'change', '[name="protocol[research_types_info_attributes][human_subjects]"]', ->
    if $(this).prop('checked')
      $('#protocol_research_master_id').siblings('label').addClass('required')
      $('#protocol_human_subjects_info_attributes_approval_pending').bootstrapToggle('enable')
      $('[name="protocol[human_subjects_info_attributes][approval_pending]"').attr('disabled', false)
    else
      $('#protocol_research_master_id').siblings('label').removeClass('required')
      $('#protocol_human_subjects_info_attributes_approval_pending').bootstrapToggle('disable')
      $('[name="protocol[human_subjects_info_attributes][approval_pending]"').attr('disabled', true)
    setRequiredFields()

  $(document).on 'keyup', '#protocol_investigational_products_info_attributes_ind_number', ->
    if $(this).val().length > 0
      $('#protocol_investigational_products_info_attributes_ind_on_hold').bootstrapToggle('enable')
      $('[name="protocol[investigational_products_info_attributes][ind_on_hold]"]').attr('disabled', false)
    else
      $('#protocol_investigational_products_info_attributes_ind_on_hold').bootstrapToggle('off').bootstrapToggle('disable')
      $('[name="protocol[investigational_products_info_attributes][ind_on_hold]"]').attr('disabled', true)

  $(document).on 'change', '#protocol_investigational_products_info_attributes_exemption_type', ->
    exemption = $(this).val()

    $('.device-container').addClass('d-none')
    $('.device-container input').val('').attr('disabled', true)
    $(".device-container##{exemption}DeviceContainer").removeClass('d-none').children('input').attr('disabled', false)

  $(document).on 'change', '.impact-area', ->
    $specifyField = $('#' + $(this).prop('id').replace('__destroy', '_other_text'))

    if $specifyField.length > 0
      if $(this).prop('checked')
        $specifyField.parents('.form-group').removeClass('d-none')
      else
        $specifyField.parents('.form-group').addClass('d-none')

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
  $('#primary_pi:not([readonly=readonly])').typeahead(
    {
      minLength: 3
      hint: false
      highlight: true
    }, {
      displayKey: 'label'
      source: identitiesBloodhound.ttAdapter()
      limit: 100,
      templates: {
        notFound: "<div class='tt-suggestion'>#{I18n.t('constants.search.no_results')}</div>",
        pending: "<div class='tt-suggestion'>#{I18n.t('constants.search.loading')}</div>"
      }
    }
  ).on 'typeahead:select', (event, suggestion) ->
    $('#protocol_primary_pi_role_attributes_identity_id').val(suggestion.value)
    $('#lazy_identity_id').val(suggestion.lazy_id)
    $('#primary_pi').prop('placeholder', suggestion.label)
    $('#primary_pi').parents('.form-group').addClass('is-valid')

  ##################################
  ### Study Type Questions Logic ###
  ##################################

  $(document).on 'change', '[name="protocol[selected_for_epic]"]', ->
    $('[for=protocol_selected_for_epic]').addClass('required')

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

rmidAjax = null

updateRmidFields = () ->
  if rmid = $('#protocol_research_master_id:not([readonly=readonly])').val()
    if rmidAjax
      rmidAjax.abort()

    rmidAjax = $.ajax(
      method: 'get'
      dataType: 'script'
      url: '/protocols/validate_rmid'
      data:
        protocol_id: $('#protocol_id').val()
        protocol:
          research_master_id: rmid
    )

resetRmidFields = () ->
  $('#protocol_research_master_id').parents('.form-group').removeClass('is-valid is-invalid')
  $('#protocol_short_title').val('').prop('readonly', false)
  $('#protocol_title').val('').prop('readonly', false)
  $('#protocol_human_subjects_info_attributes_pro_number').val('').prop('readonly', false)
  $('#protocol_human_subjects_info_attributes_initial_irb_approval_date').prop('readonly', false).datetimepicker('clear')
  $('#protocol_human_subjects_info_attributes_irb_approval_date').prop('readonly', false).datetimepicker('clear')
  $('#protocol_human_subjects_info_attributes_irb_expiration_date').prop('readonly', false).datetimepicker('clear')

fundingSource             = ""
potentialFundingSource    = ""
fundingStartDate          = ""
potentialFundingStartDate = ""

toggleFundingSource = (val) ->
  if val == ''
    $('#fundingSourceContainer').removeClass('d-none')
    $('#potentialFundingSourceContainer').addClass('d-none')
    $('#protocol_funding_source, #protocol_potential_funding_source').attr('disabled', true).selectpicker('val', '').selectpicker('refresh')
    $('#protocol_funding_start_date, #protocol_potential_funding_start_date').prop('readonly', true).datetimepicker('clear')
  else
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

    $('#protocol_funding_source, #protocol_potential_funding_source').attr('disabled', false).selectpicker('refresh')


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
  $select.closest('.form-row').addClass('d-none')

showStudyTypeQuestion = ($select) ->
  $select.trigger('change')
  $select.closest('.form-row').removeClass('d-none')

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
