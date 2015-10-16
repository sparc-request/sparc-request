archive_button_sel  = ".protocol-archive-button[data-protocol_id=#{<%= @protocol.id %>}]"
archive_button_text = $(archive_button_sel).text()

if <%= @protocol.archived %>
  if $('.archive_button').data('showing-archived') == 0
    $("#blue-provider-#{<%= @protocol.id %>}").hide()
    $(".protocol-information-#{<%= @protocol.id %>}").hide()

  $(archive_button_sel).text(archive_button_text.replace("ARCHIVE", "UNARCHIVE"))
else
  $(archive_button_sel).text(archive_button_text.replace("UNARCHIVE", "ARCHIVE"))

if $(archive_button_sel).data('archive') == '0'
  $(archive_button_sel).data('archive', '1')
else
  $(archive_button_sel).data('archive', '0')
