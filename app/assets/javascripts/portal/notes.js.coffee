$ ->

  # NOTES LISTENERS BEGIN
  $(document).on 'click', 'button.notes.list',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    data          = note:
                      notable_id: id,
                      notable_type: type
    $.ajax
      type: 'GET'
      url: '/portal/notes'
      data: data

  $(document).on 'click', 'button.note.new',  ->
    id = $(this).data('notable-id')
    type = $(this).data('notable-type')
    data          = note:
                      notable_id: id,
                      notable_type: type
    $.ajax
      type: 'GET'
      url: '/portal/notes/new'
      data: data
  # NOTES LISTENERS END
