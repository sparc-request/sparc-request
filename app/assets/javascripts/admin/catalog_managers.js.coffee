$(document).ready ->

  # The export button is rendered in the table data settings (show-export: 'true'), and this hides the option to select a format type (as we will export to csv only).
  $('#overlordsCard .export button').addClass('no-caret').siblings('.dropdown-menu').addClass('d-none')

  # For exporting table data, this redirects to the 'index' method 'csv' format response in the admin/overlords controller.
  $('#overlordsCard .export button').on 'click', ->
    url = new URL($('#overlordsTable').data('url'), window.location.origin)
    url.pathname = url.pathname.replace('json', 'csv')
    window.location = url