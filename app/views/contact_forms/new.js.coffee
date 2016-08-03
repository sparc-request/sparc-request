# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
formDialog = $('.contact-form-dialog').html("<%= escape_javascript render 'form' %>").dialog(
  height: 400
  width: 500
  modal: true
  title: 'Contact Us'
)

$('.new_contact_form').on 'ajax:success', ->
  formDialog.dialog('close')
  $('.align-element-nav-bar').html('<div id="flash_notice">Message sent</div>')