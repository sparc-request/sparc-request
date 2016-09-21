# Copyright © 2011-2016 MUSC Foundation for Research Development
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
  autoComplete = $('#user_search_term').autocomplete
    source: '/search/identities'
    minLength: 3
    search: (event, ui) ->
      $('.user-search-clear-icon').remove()
      $('.user-search-spinner').remove()
      $("#user_search_term").after('<img src="/assets/spinner.gif" class="user-search-spinner" />')
    open: (event, ui) ->
      $('.user-search-spinner').remove()
      $("#user_search_term").after('<img src="/assets/clear_icon.png" class="user-search-clear-icon" />')
    close: (event, ui) ->
      $('.user-search-spinner').remove()
      $('.user-search-clear-icon').remove()
    select: (event, ui) ->
      data = 'portal' : $('#portal').val()
      $.ajax
        url: "/identities/#{ui.item.value}"
        type: 'GET'
        data: data
      $('#user_search_term').clearFields()
      $('.add-user-details').show()
      return false

  .data("uiAutocomplete")._renderItem = (ul, item) ->
    if item.label == 'No Results'
      $("<li class='search_result'></li>")
      .data("ui-autocomplete-item", item)
      .append("#{item.label}")
      .appendTo(ul)
    else
      $("<li class='search_result'></li>")
      .data("ui-autocomplete-item", item)
      .append("<a>" + item.label + "</a>")
      .appendTo(ul)

  $('.user-search-clear-icon').live 'click', ->
    $("#user_search_term").autocomplete("close")
    $("#user_search_term").clearFields()

  $('#user_search_term').keypress (event) ->
    event.preventDefault() if event.keyCode is 13
