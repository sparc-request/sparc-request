$(document).ready ->

  $(document).on 'click', 'button#documents_application',  ->
    $('.document_nav').removeClass('btn-primary').addClass('btn-default')
    $(this).removeClass('btn-default').addClass('btn-primary')
    $('#document_tabs').data('selected', 'application')
    $('#document-table').bootstrapTable 'refresh', { query: { table: 'application' } }

  $(document).on 'click', 'button#documents_loi',  ->
    $('.document_nav').removeClass('btn-primary').addClass('btn-default')
    $(this).removeClass('btn-default').addClass('btn-primary')
    $('#document_tabs').data('selected', 'loi')
    $('#document-table').bootstrapTable 'refresh', { query: { table: 'loi' } }