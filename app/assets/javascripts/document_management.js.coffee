# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#= require navigation

$(document).ready ->

  $(".document_upload_button").click ->
    $("#process_ssr_organization_ids").removeAttr('disabled')
    $("#document").removeAttr('disabled')
    $(".document_upload_button").hide()
    $('#doc_type').change()

  $(".document_edit").click ->
    $("#process_ssr_organization_ids").removeAttr('disabled')
    $("#document").removeAttr('disabled')
    $(".document_upload_button").hide()
    $('.document_edit span').html('Loading...')
    $('.document_delete').hide()

  $("#cancel_upload").live 'click', ->
    $("#process_ssr_organization_ids").attr('disabled', 'disabled')
    $("#document").attr('disabled', 'disabled')
    $('.document_delete').show()

  $(document).on('change', '#doc_type', ->
    if $(this).val() == 'other'
      $('.document_type_other').show()
    else
      $('.document_type_other').hide()
  )

  $(".new_request_note_button").click ->
    $('#note_form').show()
    $("#new_note_text").focus()
    $(this).hide()

  $("#save_request_note").click ->
    data =
      in_proper: true
      note:
        notable_id: $(this).data('notable-id')
        notable_type: $(this).data('notable-type')
        body: $("#new_note_text").val()
    $("#new_note_text").val("")
    $.ajax
      type: 'POST'
      url: '/dashboard/notes'
      data: data
