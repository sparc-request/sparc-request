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

$(document).ready ->

  $(document).on 'change', "#study_funding_status", ->
    # Proposal Funding Status - Dropdown
    $(".funding_status_dependent").hide()
    switch $(this).val()
      when "funded"
        $(".funded").show()
        $("#study_funding_source").trigger("change")
      when "pending_funding" then $(".pending_funding").show()

  $(document).on 'change', "#study_funding_source", ->
    # Funding Source - Dropdown
    $(".funding_source_dependent").hide()
    switch $(this).val()
      when "federal" then $(".federal").show()
      when "internal" then $(".internal").show()

  $(document).on 'change', "input[name='study[selected_for_epic]']", ->
    # Publish Study in Epic - Radio
    switch $(this).val()
      when "true" then $(".selected_for_epic_dependent").show()
      when "false" then $(".selected_for_epic_dependent").hide()

  $(document).on 'change', "#study_research_types_info_attributes_human_subjects", ->
    # Human Subjects - Checkbox
    switch $(this).attr('checked')
      when 'checked' then $('.human_subjects_dependent').show()
      else $('.human_subjects_dependent').hide()

  $(document).on 'change', "#study_research_types_info_attributes_vertebrate_animals", ->
    # Vertebrate Animals - Checkbox
    switch $(this).attr('checked')
      when 'checked' then $('.vertebrate_animals_dependent').show()
      else $('.vertebrate_animals_dependent').hide()

  $(document).on 'change', "#study_research_types_info_attributes_investigational_products", ->
    # Investigational Products - Checkbox
    switch $(this).attr('checked')
      when 'checked' then $('.investigational_products_dependent').show()
      else $('.investigational_products_dependent').hide()

  $(document).on 'change', "#study_research_types_info_attributes_ip_patents", ->
    # IP/Patents - Checkbox
    switch $(this).attr('checked')
      when 'checked' then $('.ip_patents_dependent').show()
      else $('.ip_patents_dependent').hide()

  $(document).on 'change', "#study_impact_areas_attributes_6__destroy", ->
    # Impact Areas Other - Checkbox
    switch $(this).attr('checked')
      when 'checked' then $('.impact_area_dependent').show()
      else $('.impact_area_dependent').hide()

  $(document).on 'change', "#project_funding_status", ->
    # Proposal Funding Status - Dropdown
    $(".funding_status_dependent").hide()
    switch $(this).val()
      when "funded" then $(".funded").show()
      when "pending_funding" then $(".pending_funding").show()



  #********** Primary PI TypeAhead Input Handling Begin **********
  if $('#study_project_roles_attributes_0_identity_id[type="text"]').length > 0
    identities_bloodhound = new Bloodhound(
      datumTokenizer: (datum) ->
        Bloodhound.tokenizers.whitespace datum.value
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: '/search/identities?term=%QUERY',
        wildcard: '%QUERY'
    )
    identities_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
    $('#study_project_roles_attributes_0_identity_id[type="text"]').typeahead(
      # Instantiate the Typeahead UI
      {
        minLength: 3,
        hint: false,
        highlight: true
      },
      {
        displayKey: 'label'
        source: identities_bloodhound.ttAdapter()
      }
    )
    .on 'typeahead:select', (event, suggestion) ->
      $("#study_project_roles_attributes_0_identity_id[type='hidden']").val(suggestion.value)
      $("#study_project_roles_attributes_0_identity_id[type='text']").hide()
      $("#primary_pi_name").text("#{suggestion.label}").show()
      $("#user-select-clear-icon").show()

    $('#user-select-clear-icon').live 'click', ->
      $("#primary_pi_name").text("").hide()
      $('#user-select-clear-icon').hide()
      $("#study_project_roles_attributes_0_identity_id[type='hidden']").val('')
      $("#study_project_roles_attributes_0_identity_id[type='text']").val('').show()
  #********** Primary PI TypeAhead Input Handling End **********
