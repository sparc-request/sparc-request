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

#= require cart

$(document).ready ->
  getSRId = () ->
    $('input[name="service_request_id"]').val()

  ### ACCORDION LOGIC ###
  $(document).on 'click', '.institution-header, .provider-header, .program-link:not(.locked-program)', ->
    if $(this).hasClass('institution-header')
      $('.institution-header').removeClass('clicked')
      $('.provider-header').removeClass('clicked')
      $('.program-link').removeClass('clicked')
    else if $(this).hasClass('provider-header')
      $('.provider-header').removeClass('clicked')
      $('.program-link').removeClass('clicked')
    else if $(this).hasClass('program-link')
      $('.program-link').removeClass('clicked')
    $(this).addClass('clicked')
    id    = $(this).data('id')
    data =
      process_ssr_found: $(this).data('process-ssr-found')
      service_request_id: getSRId()
      sub_service_request_id: $('input[name="sub_service_request_id"]').val()
    $.ajax
      type: 'POST'
      data: data
      url: "/catalogs/#{id}/update_description"

  $(document).on 'click', '.program-link.locked-program', ->
    organizationId = $(this).data('id')
    protocolId = $('.protocol-id').val()
    serviceRequestId = $('.service-request-id').val()
    $.ajax
      type: 'GET'
      url: "/locked_organizations?org_id=#{organizationId}&protocol_id=#{protocolId}&service_request_id=#{serviceRequestId}"

  $(document).on 'click', '.core-header', ->
    $('.service-description').addClass('hidden')

  $(document).on 'click', '.service', ->
    description = $(".service-description-#{$(this).data('id')}")
    if description.hasClass('hidden')
      $('.service-description').addClass('hidden')
      description.removeClass('hidden')
    else
      description.addClass('hidden')

  ### SERVICE SEARCH BLOODHOUND ###
  services_bloodhound = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote:
      url: "/search/services?term=%QUERY&service_request_id=#{getSRId()}",
      wildcard: '%QUERY'
  )
  services_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
  $('#service-query').typeahead(
    {
      minLength: 3,
      hint: false,
    },
    {
      displayKey: 'term',
      source: services_bloodhound,
      limit: 100,
      templates: {
        suggestion: Handlebars.compile('<button class="text-left" data-container="body" data-placement="right" data-toggle="tooltip" data-animation="false" title="{{description}}">
                                          <span><strong class="{{inst_css_class}}">{{institution}}</strong>{{parents}}</span><br>
                                          <span><strong>Service: {{label}}</strong></span><br>
                                          <span><strong>Abbreviation: {{abbreviation}}</strong></span><br>
                                          <span><strong>CPT Code: {{cpt_code}}</strong></span>
                                        </button>')
        notFound: '<div class="tt-suggestion">No Results</div>'
      }
    }
  ).on('typeahead:render', (event, a, b, c) ->
    $('[data-toggle="tooltip"]').tooltip({ 'delay' : { show: 1000, hide: 500 } })
  ).on('typeahead:select', (event, suggestion) ->
    window.cart.selectService(suggestion.value, $(this).data('srid'), $(this).data('ssrid'))
  )

  ### CONTINUE BUTTON ###
  $(document).on 'click', '.submit-request-button', ->
    signed_in = parseInt($('#signed_in').val())
    if signed_in == 0
      window.location.href = $('#login-link').attr('href')
      return false
    else if $('#line_item_count').val() <= 0
      $('#modal_place').html($('#submit-error-modal').html())
      $('#modal_place').modal('show')
      $('.modal #submit-error-modal').removeClass('hidden')
      return false

  $(window).scroll ->
    if $(this).scrollTop() > 50
      $('.back-to-top').removeClass('hidden')
    else
      $('.back-to-top').addClass('hidden')
