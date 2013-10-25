$(document).ready ->
  $('form.new_cover_letter, form.edit_cover_letter').submit ->
    $('#cover_letter_content').val( $('#cover_letter_content_editor').html() )