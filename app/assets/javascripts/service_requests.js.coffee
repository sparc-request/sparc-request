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

  #####################
  ### Save As Draft ###
  #####################

  $(document).on 'click', '#saveAsDraft', ->
    ConfirmSwal.fire(
      title: I18n.t('proper.navigation.save_as_draft.title')
      html: I18n.t('proper.navigation.save_as_draft.text')
    ).then (result) ->
      if result.value
        $.ajax
          method: 'PUT'
          dataTyp: 'script'
          url: '/service_request/save_and_exit'
          data: $('.milestone-field input').serialize() + "&srid=#{getSRId()}"

  ###################
  ### Add Service ###
  ###################

  $(document).on 'click', '.add-service', ->
    $(this).prop('disabled', true)
    $this = $(this)
    service_id = $(this).data('service-id')

    $.ajax
      method: 'POST'
      dataType: 'script'
      url: '/service_request/add_service'
      data:
        srid: getSRId()
        service_id: service_id
      complete: ->
        $this.prop('disabled', false)

  ###############
  ### Catalog ###
  ###############

  $(document).on 'click', '#institutionAccordion .org-link', ->
    id = $(this).data('id')

    if $(this).hasClass('locked')
      $.ajax
        type: 'get'
        dataType: 'script'
        url: "/catalogs/#{id}/locked_organization"
        data:
          srid: getSRId()
    else
      $.ajax
        type: 'get'
        dataType: 'script'
        url: "/catalogs/#{id}/update_description"
        data:
          srid: getSRId()

  $(document).on('submit', '#serviceCatalogForm', (event) ->
    if $('#cart #activeServices .sub-service-request, #cart #completedServices .sub-service-request').length == 0
      event.preventDefault()
      AlertSwal.fire(
        type: 'error'
        title: I18n.t('proper.catalog.services_missing.header')
        text: I18n.t('activerecord.errors.models.service_request.attributes.line_items.blank')
      )
      $('html, body').animate({ scrollTop: $('#stepsHeader').offset().top }, 'slow')
  ).on('click', '#stepsNav .nav-link:not(.active)', (event) ->
    if $('#serviceCatalogForm').length && $('#cart #activeServices .sub-service-request, #cart #completedServices .sub-service-request').length == 0
      $(this).trigger('blur')
      event.preventDefault()
      AlertSwal.fire(
        type: 'error'
        title: I18n.t('proper.catalog.services_missing.header')
        text: I18n.t('activerecord.errors.models.service_request.attributes.line_items.blank')
      )
      $('html, body').animate({ scrollTop: $('#stepsHeader').offset().top }, 'slow')
  )

  servicesBloodhound = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: "/search/services?term=%TERM&srid=#{getSRId()}",
      wildcard: '%TERM'
  )

  servicesBloodhound.initialize()

  $(document).on 'mouseleave', '#serviceQuery + .tt-menu .tt-suggestion', (e) ->
    console.log e

  $('#serviceQuery').typeahead(
    {
      minLength: 3,
      hint: false,
    }, {
      displayKey: 'term',
      source: servicesBloodhound.ttAdapter(),
      limit: 100,
      templates: {
        notFound: "<div class='tt-suggestion'>#{I18n.t('constants.search.no_results')}</div>",
        pending: "<div class='tt-suggestion'>#{I18n.t('constants.search.loading')}</div>",
        suggestion: (s) -> [
          "<div class='tt-suggestion' data-toggle='#{if s.description then 'popover' else ''}' data-title='#{s.name}' data-content='#{escapeHTML(s.description)}' data-boundary='window' data-placement='left' data-trigger='hover' data-html='true'>",
            "<div class='w-100'>",
              "<h5 class='mb-0'><span class='text-service'>#{I18n.t('activerecord.models.service.one')}: </span>#{s.name}</h5>",
            "</div>",
            "<div class='w-100'>#{s.breadcrumb}</div>",
            "<div class='w-100'>",
              "<span><strong>#{I18n.t('activerecord.attributes.service.abbreviation')}: </strong>#{s.abbreviation}</span>",
            "</div>",
            s.cpt_code_text,
            s.eap_id_text,
            s.pricing_text,
          "</div>"
        ].join('')
      }
    }
  ).on('typeahead:render', ->
    initializePopovers()
  ).on('typeahead:select', (event, suggestion) ->
    $.ajax
      method: 'post'
      dataType: 'script'
      url: '/service_request/add_service'
      data:
        srid:       getSRId()
        service_id: suggestion.service_id
  )
