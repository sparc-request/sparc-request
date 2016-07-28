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

#= require cart

$(document).ready ->
  ### Related to locked service requests ###
  $('#ctrc-dialog').dialog
    autoOpen: false
    modal: true
    width: 375
    height: 200
    buttons: [{
      text: 'Ok'
      click: ->
        $(this).dialog('close')
    }]

  $(document).on 'click', '.locked a', ->
    if $(this).text() == 'Research Nexus **LOCKED**'
      $('#ctrc-dialog').dialog('open')

  ### Organization Accordion Logic ###
  $('#institution-accordion').accordion
    heightStyle: 'content'
    collapsible: true

  $('.provider-accordion').accordion
    heightStyle: 'content'
    collapsible: true
    active: false


  $(document).on 'click', '.institution-header, .provider-header', ->
    $('#processing-request').removeClass('hidden')
    id    = $(this).data('id')
    $.ajax
      type: 'POST'
      url: "/catalogs/#{id}/update_description"
      success: ->
        $('#processing-request').addClass('hidden')

  $(document).on 'click', '.program-link', ->
    $('#processing-request').removeClass('hidden')
    id    = $(this).data('id')
    data  = process_ssr_found : $(this).data('process-ssr-found') 
    $.ajax
      type: 'POST'
      data: data
      url: "/catalogs/#{id}/update_description"
      success: ->
        $('#processing-request').addClass('hidden')

  $(document).on 'click', '.core-header', ->
    $('.service-description').addClass('hidden')

  $(document).on 'click', '.service-view a', ->
    description = $(".service-description-#{$(this).data('id')}")
    if description.hasClass('hidden')
      $('.service-description').addClass('hidden')
      description.removeClass('hidden')
    else
      description.addClass('hidden')






  # Initialize Authorized Users Searcher
  identities_bloodhound = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote:
      url: '/search/services?term=%QUERY',
      wildcard: '%QUERY'
  )
  identities_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
  $('#service-query').typeahead(
    {
      minLength: 3,
      hint: false,
    },
    {
      displayKey: 'term',
      source: identities_bloodhound,
      limit: 100,
      templates: {
        suggestion: Handlebars.compile('<div data-toggle="tooltip" data-placement="right" title="{{description}}">
                                          <span>{{parents}}</span><br>
                                          <span><strong>Service: {{label}}</strong></span><br>
                                          <span><strong>Abbreviation: {{abbreviation}}</strong></span><br>
                                          <span><strong>CPT Code: {{cpt_code}}</strong></span>
                                        </div>')
      }
    }
  ).on('typeahead:render', (event, a, b, c) ->
    $('[data-toggle="tooltip"]').tooltip()
  ).on('typeahead:select', (event, suggestion) ->
    srid = $(this).data('srid')
    id = suggestion.value
    $.ajax
      type: 'POST'
      url: "/service_requests/#{srid}/add_service/#{id}"
  )

  $(document).on 'click', '.submit-request-button', ->
    signed_in = parseInt($('#signed_in').val())
    if signed_in == 0
      $('#modal_place').html($('#login-required-modal').html())
      $('#modal_place').modal('show')
      $('.modal #login-required-modal').removeClass('hidden')
      return false
    else if $('#line_item_count').val() <= 0
      $('#modal_place').html($('#submit-error-modal').html())
      $('#modal_place').modal('show')
      $('.modal #submit-error-modal').removeClass('hidden')
      return false
