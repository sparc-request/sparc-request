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

$("#org-form-container").html("<%= j render '/catalog_manager/shared/form', organization: @organization, user_rights: @user_rights, path: @path %>")
$('.selectpicker').selectpicker();
$("[data-toggle='toggle']").bootstrapToggle(
    on: 'Yes',
    off: 'No'
  );


## Identity Search Bloodhound
services_bloodhound = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  remote:
    url: "/search/identities?term=%QUERY",
    wildcard: '%QUERY'
)
services_bloodhound.initialize() # Initialize the Bloodhound suggestion engine


## User Search for User Rights Sub-Form
$('#user-rights-query').typeahead(
  {
    minLength: 3,
    hint: false,
  },
  {
    displayKey: 'term',
    source: services_bloodhound,
    limit: 100,
    templates: {
      suggestion: Handlebars.compile("<button class=\"text-left col-sm-12\">
                                        <strong>{{name}}</strong> <span>{{email}}{{identity_id}}</span>
                                      </button>")
      notFound: '<div class="tt-suggestion">No Results</div>'
    }
  }
).on('typeahead:select', (event, suggestion) ->
  users_on_table = $("[id*='user-rights-row-']").map ->
    return $(this).data('identity-id')

  if suggestion['identity_id'] in users_on_table
    $('#user-rights-query').parent().prepend("<div class='alert alert-danger alert-dismissable'>#{suggestion['name']} #{I18n['catalog_manager']['organization_form']['user_rights']['user_in_table']}</div>")
    $('.alert-dismissable').delay(3000).fadeOut()
  else
    $.ajax
      type: 'get'
      url: "/catalog_manager/organizations/<%= @organization.id %>/add_user_rights_row.js"
      data:
        new_ur_identity_id: suggestion['identity_id']
)


##User Search for Fulfillment Sub-Form
##ToDo After User Rights is re-done
