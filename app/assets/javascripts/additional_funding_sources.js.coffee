# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(document).on 'changed.bs.select', '#additional_funding_source_funding_source', '#protocol_additional_funding_source_attributes_funding_source', ->
    if $(this).val() == 'federal'
      $('#federalGrantFields').removeClass('d-none')
    else
      $('#federalGrantFields').addClass('d-none')

    if $(this).val() == 'internal'
      $('#additionalFundingSourceOtherContainer').removeClass('d-none')
    else
      $('#additionalFundingSourceOtherContainer').addClass('d-none')

  $(document).on 'change', '#additional_funding_source_phs_sponsor', ->
    if $('#additional_funding_source_non_phs_sponsor').val()
      $('#additional_funding_source_non_phs_sponsor').selectpicker('val', '')

  $(document).on 'change', '#additional_funding_source_non_phs_sponsor', ->
    if $('#additional_funding_source_phs_sponsor').val()
      $('#additional_funding_source_phs_sponsor').selectpicker('val', '')
