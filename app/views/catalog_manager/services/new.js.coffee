# Initialize Authorized Users Searcher
identities_bloodhound = new Bloodhound(
  datumTokenizer: (datum) ->
    Bloodhound.tokenizers.whitespace datum.value
  queryTokenizer: Bloodhound.tokenizers.whitespace
  remote:
    "/search/related_services?term=%QUERY"
    url: "/search/related_services?term=%QUERY",
    wildcard: '%QUERY'
)
identities_bloodhound.initialize() # Initialize the Bloodhound suggestion engine
$('#new_related_services_search').typeahead(
  # Instantiate the Typeahead UI
  {
    minLength: 3,
    hint: false,
    highlight: true
  },
  {
    displayKey: 'label'
    source: identities_bloodhound.ttAdapter()
    limit: 100
  }
)
.on 'typeahead:select', (event, suggestion) ->
  $("#loading_authorized_user_spinner").removeClass('hidden')
  $.ajax
    type: 'get'
    url: '/dashboard/associated_users/new.js'
    data:
      protocol_id: $(this).data('protocol-id')
      identity_id: suggestion.value
      service_request_id: getSRId()
    success: ->
      $("#loading_authorized_user_spinner").addClass('hidden')