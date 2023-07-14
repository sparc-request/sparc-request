$ ->

  # The export button is rendered in the table data settings (show-export: 'true'), and this hides the option to select a format type (as we will export to csv only).
  $('#settingsCard .export button').addClass('no-caret').siblings('.dropdown-menu').addClass('d-none')

  # The search in this table does not send calls with params to the server when filtering results (due to client-side pagination, all objects are preloaded) - so we cannot grab those params and use them to assist with exporting matching database objects in the controller action as we do with identities. As a result, this must be simulated using ajax calls from the front end. STEP 1, STEP 2, and STEP 3 below execute this process.
  
  # STEP 1: This function creates a 1000 ms delay after 'keyup' in the table search bar.
  addSearchInputCallback = (searchInput, callback, delay) ->
    timer = null

    searchInput.onkeyup = ->
      if timer
        window.clearTimeout timer
      timer = window.setTimeout((->
        timer = null
        callback()
        return
      ), delay)
      return
    
    searchInput = null
    return

  # STEP 2: This function grabs the string input from the table search bar and sends it to the 'index' method of the admin/settings controller via ajax request where it is used to filter and return relevant database objects on the back end.
  simulateServerCall = ->
    searchInput = $('#settingsCard .search-input').val()
    $.ajax {
      type: 'get'
      url: '' + 'settings.json'
      contentType: 'application/json'
      dataType: 'json'
      data: { search: searchInput, sort: 'group', order: 'desc' }
      success: (data) ->
        console.log 'Search param data sent to controller.'
      error: (data) ->
        console.log 'Error sending search param data to controller'
    }

  # STEP 3: Executing STEP 1 and STEP 2 conditionally, only if you are in the admin/settings table view.
  if $('#settingsCard').length
    addSearchInputCallback $('#settingsCard .search-input')[0], simulateServerCall, 1000

  

  # For exporting table data, this redirects to the 'index' method 'csv' format response in the admin/settings controller.
  $('#settingsCard .export button').on 'click', ->
    url = new URL($('#settingsTable').data('url'), window.location.origin)
    url.pathname = url.pathname.replace('json', 'csv')
    window.location = url