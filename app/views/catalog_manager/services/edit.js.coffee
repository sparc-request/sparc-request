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

$("#org-form-container").html("<%= j render '/catalog_manager/services/form', service: @service, user_rights: @user_rights %>")
$('.selectpicker').selectpicker();
$("[data-toggle='toggle']").bootstrapToggle(
    on: 'Yes',
    off: 'No'
  );

###############################
### RELATED SERVICES SEARCH ###
###############################

services_bloodhound = new Bloodhound(
  datumTokenizer: (datum) ->
    Bloodhound.tokenizers.whitespace datum.value
  queryTokenizer: Bloodhound.tokenizers.whitespace
  remote:
    url: "/search/services_search?term=%QUERY",
    wildcard: '%QUERY'
)
services_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
$('#new_related_services_search').typeahead(
  # Instantiate the Typeahead UI
  {
    minLength: 3,
    hint: false,
    highlight: true
  },
  {
    displayKey: 'term'
    source: services_bloodhound.ttAdapter()
    limit: 100
    templates: {
      suggestion: Handlebars.compile('<button class="text-left">
                                        <strong><span class="text-service">Service</span><span>: {{name}}</span></strong><br>
                                        {{#if cpt_code}}
                                          <span><strong>CPT Code: {{cpt_code}}</strong></span>
                                        {{/if}}
                                      </button>')
      notFound: '<div class="tt-suggestion">No Results</div>'
    }
  }
)
.on('typeahead:select', (event, suggestion) ->
  existing_services = $("[id*='service-relation-id-']").map ->
    return $(this).data('related-service-id')

  if suggestion['id'] in existing_services
    $('#new_related_services_search').parent().prepend("<div class='alert alert-danger alert-dismissable'>#{suggestion['name']} #{I18n['catalog_manager']['related_services_form']['service_in_list']}</div>")
    $('.alert-dismissable').delay(3000).fadeOut()
  else
    $.ajax
      type: 'post'
      url: '/catalog_manager/services/add_related_service'
      data:
        service: $(this).data('service')
        related_service: suggestion.id
)
