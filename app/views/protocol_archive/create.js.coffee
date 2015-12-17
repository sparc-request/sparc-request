archive_button_sel  = ".protocol-archive-button[data-protocol-id=#{<%= @protocol.id %>}]"
archive_button_text = $(archive_button_sel).text()
console.log $(archive_button_sel)
console.log(archive_button_text)

if <%= @protocol.archived %>
  if $('.archive_button').data('showing-archived') == 0
    $(".protocol-information-panel-#{<%= @protocol.id %>}").hide()

  $(archive_button_sel).text(archive_button_text.replace("Archive", "Unarchive"))
else
  $(archive_button_sel).text(archive_button_text.replace("Unarchive", "Archive"))

if $(archive_button_sel).data('archive') == '0'
  $(archive_button_sel).data('archive', '1')
else
  $(archive_button_sel).data('archive', '0')
