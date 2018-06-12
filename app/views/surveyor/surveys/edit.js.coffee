# Copyright © 2011-2017 MUSC Foundation for Research Development
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
$('#modal_place').html("<%= j render 'surveyor/surveys/form/survey_form', survey: @survey, modal_title: @modal_title %>")
$('#modal_place').modal('show')
$('.selectpicker').selectpicker()

<% if @survey.is_a?(SystemSurvey) %>
$('.survey-table').bootstrapTable('refresh')
<% end %>

surveyable_bloodhound = new Bloodhound(
  datumTokenizer: (datum) ->
    Bloodhound.tokenizers.whitespace datum.value
  queryTokenizer: Bloodhound.tokenizers.whitespace
  remote:
    url: "/surveyor/survey/search_surveyables?term=%QUERY",
    wildcard: '%QUERY'
)
surveyable_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
$("#modal_place [id$='-surveyable']").typeahead(
  {
    minLength: 3
    hint: false
    highlight: true
  }
  {
    displayKey: 'label'
    source: surveyable_bloodhound,
    limit: 100,
    templates: {
      suggestion: Handlebars.compile('<button class="text-left">
                                        {{#if parents}}
                                          <strong>{{{parents}}}</strong><br>
                                        {{/if}}
                                        <span><strong>{{label}}</strong></span>
                                        {{#if cpt_code}}
                                          <br><span><strong>CPT Code: {{cpt_code}}</strong></span>
                                        {{/if}}
                                      </button>')
      notFound: '<div class="tt-suggestion">No Results</div>'
    }
  }
).on('typeahead:select', (event, suggestion) ->
  $(this).data('surveyable', "#{suggestion.klass}-#{suggestion.value}")

  $.ajax
    type: 'put'
    url: "/surveyor/survey_updater/#{$(this).attr('id').split('-')[1]}.js"
    data:
      klass: "survey"
      survey:
        surveyable_id: suggestion.value
        surveyable_type: suggestion.klass
    success: ->
      $("#survey-<%= @survey.id %>-surveyable").prop('placeholder', suggestion.label)
      $("#survey-<%= @survey.id %>-active").prop('disabled', false)
      $("#survey-<%= @survey.id %>-active").tooltip('disable')
)
