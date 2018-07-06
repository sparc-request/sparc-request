# Copyright © 2011-2018 MUSC Foundation for Research Development
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

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  initialize_org_search()
  initialize_glyphicon()


  $(document).on 'change','#show_available_only', ->
    show_available_only = $(this).prop('checked')
    $.ajax
      method: "GET"
      url: "/catalog_manager.js?show_available_only=#{show_available_only}"
      success: ->
        initialize_org_search()
        initialize_glyphicon()
        $("[data-toggle='toggle']").bootstrapToggle()


  ##############################################
  ###          Create New Organization       ###
  ##############################################

  $(document).on 'click', '.new_organization_link', ->
    org_type = $(this).data('organization-type')
    parent_id = $(this).data('parent-id')
    $.ajax
      type: 'GET'
      url: 'catalog_manager/organizations/new.js'
      data:
        type: org_type
        parent_id: parent_id

  ##############################################
  ###          Create New Service            ###
  ##############################################

  $(document).on 'click', '.new_service_link', ->
    organization_id = $(this).data('organization-id')
    $.ajax
      type: 'GET'
      url: 'catalog_manager/services/new.js'
      data:
        organization_id: organization_id


##############################################
########## Accordion Ajax Functions ##########
##############################################

  $(document).on 'click', '.load_core_accordion .glyphicon-folder-close', ->
    core_id = $(this).parent().data('core-id')
    show_available_only = $(this).parent().data('show-available-only')
    $("#core_accordion_#{core_id}").empty()
    $.ajax
      type: 'GET'
      url: 'catalog_manager/catalog/load_core_accordion'
      data:
        core_id: core_id
        show_available_only: show_available_only

  $(document).on 'click', '.load_program_accordion .glyphicon-folder-close', ->
    program_id = $(this).parent().data('program-id')
    show_available_only = $(this).parent().data('show-available-only')
    $("#program_accordion_#{program_id}").empty()
    $.ajax
      type: 'GET'
      url: 'catalog_manager/catalog/load_program_accordion'
      data:
        program_id: program_id
        show_available_only: show_available_only


##############################################
########## Glyphicon Change Function #########
##############################################

initialize_glyphicon = () ->
  $('.collapse').on('show.bs.collapse', (e) ->
    $(e.target).prev('.panel-heading').find('.glyphicon-folder-close').removeClass('glyphicon-folder-close').addClass('glyphicon-folder-open')
  ).on('hide.bs.collapse', (e) ->
    $(e.target).prev('.panel-heading').find('.glyphicon-folder-open').removeClass('glyphicon-folder-open').addClass('glyphicon-folder-close')
  )

##############################################
### ORGANIZATION/SERVICE SEARCH BLOODHOUND ###
##############################################

initialize_org_search = () ->
  services_bloodhound = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote:
      url: "/search/organizations?term=%QUERY&show_available_only=#{$('#show_available_only').prop('checked')}",
      wildcard: '%QUERY'
  )
  services_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
  $('#organization-query').typeahead(
    {
      minLength: 3,
      hint: false,
    },
    {
      displayKey: 'term',
      source: services_bloodhound,
      limit: 100,
      templates: {
        suggestion: Handlebars.compile('<button class="text-left">
                                          <strong><span class="{{text_color}}">{{type}}</span><span>: {{name}}</span></strong><span class="text-danger"> {{inactive_tag}}</span><br>
                                          {{{breadcrumb}}}<br>
                                          <span>Abbreviation: {{abbreviation}}</span><br>
                                          <span>{{cpt_code}}</span>
                                        </button>')
        notFound: '<div class="tt-suggestion">No Results</div>'
      }
    }
  ).on('typeahead:select', (event, suggestion) ->
    type = suggestion['type'].toLowerCase()
    id = suggestion['id']
    $.ajax
      type: 'GET'
      url: "catalog_manager/#{type}s/#{id}/edit"
  )

