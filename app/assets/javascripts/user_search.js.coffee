$(document).ready ->
  autoComplete = $('#user_search_term').autocomplete
    source: '/search/identities'
    minLength: 3
    search: (event, ui) ->
      $('.user-search-clear-icon').remove()
      $("#user_search_term").after('<img src="/assets/spinner.gif" class="user-search-spinner" />')
    open: (event, ui) ->
      $('.user-search-spinner').remove()
      $("#user_search_term").after('<img src="/assets/clear_icon.png" class="user-search-clear-icon" />')
    close: (event, ui) ->
      $('.user-search-spinner').remove()
      $('.user-search-clear-icon').remove()
    select: (event, ui) ->
      console.log ui
      console.log event
      console.log 'i was selected'

  .data("autocomplete")._renderItem = (ul, item) ->
    if item.label == 'No Results'
      $("<li class='search_result'></li>")
      .data("item.autocomplete", item)
      .append("#{item.label}")
      .appendTo(ul)
    else
      $("<li class='search_result'></li>")
      .data("item.autocomplete", item)
      .append("<a>" + item.label + "</a>")
      .appendTo(ul)