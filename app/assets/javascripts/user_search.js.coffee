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
      $.ajax
        url: "/identities/#{ui.item.value}"
        type: 'GET'
      $('#user_search_term').clearFields()
      $('.add-user-details').show()
      return false

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

  $('.user-search-clear-icon').live 'click', ->
    $("#user_search_term").autocomplete("close")
    $("#user_search_term").clearFields()

  $('#user_search_term').keypress (event) ->
    event.preventDefault() if event.keyCode is 13
