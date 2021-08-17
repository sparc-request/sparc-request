$("#modalContainer").html("<%= j render 'admin/overlords/select_user_form'%>")

identitiesBloodhound = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.whitespace
  queryTokenizer: Bloodhound.tokenizers.whitespace
  remote:
    url: '/search/identities?term=%TERM',
    wildcard: '%TERM'
)
identitiesBloodhound.initialize() # Initialize the Bloodhound suggestion engine
$('#user_search').typeahead(
  {
    minLength: 3,
    hint: false,
    highlight: true
  }, {
    displayKey: 'label'
    source: identitiesBloodhound.ttAdapter()
    limit: 100,
    templates: {
      notFound: "<div class='tt-suggestion'>#{I18n.t('constants.search.no_results')}</div>",
      pending: "<div class='tt-suggestion'>#{I18n.t('constants.search.loading')}</div>"
    }
  }
).on 'typeahead:select', (event, suggestion) ->
  $.ajax
    method: 'patch'
    dataType: 'script'
    url: '/admin/overlords/update'
    data:
      identity_id: suggestion.value

$("#modalContainer").modal('show')

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix