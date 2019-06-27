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
  $(document).on 'click', '#institutionAccordion .org-link:not(.licked)', ->
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

  $(document). on 'submit', '#serviceCatalogForm', (event) ->
    if $('#cart #activeServices .list-group-item').length == 0
      event.preventDefault()
      AlertSwal.fire(
        type: 'error'
        title: I18n.t('proper.catalog.services_missing.header')
        text: I18n.t('validation_errors.service_requests.line_items_missing')
      )
      $('html, body').animate({ scrollTop: $('#stepsHeader').offset().top }, 'slow')

  servicesBloodhound = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: "/search/services?term=%TERM&srid=#{getSRId()}",
      wildcard: '%TERM'
  )

  servicesBloodhound.initialize()

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
          "<div class='tt-suggestion' data-toggle='#{if s.description then 'popover' else ''}' data-title='#{s.name}' data-content='#{s.description}' data-container='body' data-boundary='window' data-placement='right' data-trigger='hover'>",
            "<div class='row'>",
              "<div class='col-12'>",
                "<h5 class='mb-0'><span class='text-service'>#{I18n.t('activerecord.models.service')}: </span>#{s.name}</h5>",
              "</div>",
              "<div class='col-12'>#{s.breadcrumb}</div>",
              "<div class='col-12'>",
                "<span><strong>#{I18n.t('activerecord.attributes.service.abbreviation')}: </strong>#{s.abbreviation}</span>",
              "</div>",
              s.cpt_code_text,
              s.eap_id_text,
              s.pricing_text,
            "</div>",
          "</div>"
        ].join('')
      }
    }
  ).on 'typeahead:select', (event, suggestion) ->
    $.ajax
      method: 'post'
      dataType: 'script'
      url: '/service_request/add_service'
      data:
        srid:       getSRId()
        service_id: suggestion.service_id
