# /////////////////////////////////////////////
# //
# // Project - Edit.js for Editing Projects
# //
# /////////////////////////////////////////////

if <%= @protocol.valid? and @current_step == 'return_to_service_request' %>
  window.location.href = "<%= protocol_service_request_path @service_request %>"
else
  #This is to re-enable the submit, it is disabled to prevent multiple posts, if you click rapidly.
  $('a.continue_button').click ->
    $('form').submit()

  $('#current_step').val("<%= @current_step %>")
  if <%= @protocol.valid? and @current_step == "user_details" %>
    $('.return-to-previous a').attr('href', "<%= edit_service_request_project_path(@service_request, @protocol) %>")
    $('.return-to-previous a span').text("Go Back")
    $('.save-and-continue span').text("Save & Continue")
    $('#errorExplanation').hide()
    $('.protocol_details_container').hide()
    $('.user-details-container').show()
  else
    $('.edit_project').html("<%= escape_javascript(render :partial => 'projects/form', :locals => {:project => @project, :service_request => @service_request}) %>")

  # $('.edit_project').html("<%= escape_javascript(render :partial => 'projects/form', :locals => {:project => @project, :service_request => @service_request}) %>")
  # $('.return-to-previous a').attr('href', "<%= edit_service_request_project_path(@service_request, @protocol) %>")
  # $('.return-to-previous a span').text("Go Back")
  # $('.save-and-continue span').text("Save & Continue")
