# /////////////////////////////////////////////
# //
# // STUDY - Edit.js for Editing Studies
# //
# /////////////////////////////////////////////

if <%= @protocol.valid? and @current_step == 'return_to_service_request' %>
  window.location.href = "<%= protocol_service_request_path @service_request %>"
else
  #This is to re-enable the submit, it is disabled to prevent multiple posts, if you click rapidly.
  $('input[type=image]').removeAttr("disabled")
  $('#current_step').val("<%= @current_step %>")
  if <%= @protocol.valid? and @current_step == "user_details" %>
    $('#errorExplanation').hide()
    $('.protocol_details_container').hide()
    $('.user-details-container').show()
  else
    $('.edit_study').html("<%= escape_javascript(render :partial => 'studies/form', :locals => {:study => @study, :service_request => @service_request}) %>")
