# Copyright © 2011-2020 MUSC Foundation for Research Development
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

$(document).ready ->
  $(document).on 'change', '#document_doc_type', ->
    if $(this).val() == 'other'
      $('#doc-type-other-field').removeClass('d-none')
    else
      $('#doc-type-other-field').addClass('d-none')

  $(document).on 'change', '#document_document', ->
   fileName = $(this).val().split('\\').pop()
   $(this).next('.custom-file-label').addClass("selected").html(fileName)

  $(document).on 'change', '#document_share_all', ->
    if $(this).prop('checked')
      $('#org_ids').parents('.form-group').addClass('d-none').removeClass('d-flex')
      $('#org_ids').prop('disabled', true).selectpicker('refresh')
    else
      $('#org_ids').parents('.form-group').removeClass('d-none').addClass('d-flex')
      $('#org_ids').prop('disabled', false).selectpicker('refresh')

  $(document).on 'change', '#documentsTable input[type="checkbox"]', ->
    if $('#documentsTable input[type="checkbox"][name^="select-document"]:checked').length == 0
      $('.download-documents').addClass('disabled')
      $('#documentsTable #select-all').prop('checked', false)
    else
      $('.download-documents').removeClass('disabled')

  $(document).on 'click', '#documentsTable #select-all', ->
    checked = $(this).prop('checked')
    $('#documentsTable tbody tr input[type="checkbox"]').each (index, row) ->
      $(this).prop('checked', checked);

  $(document).on 'click', '.download-documents', ->

    selections = $('#documentsTable input[type="checkbox"]:checked') # get all selected checkboxes
    document_ids = $.map(selections, (c) -> return c.value) # get ids of all selected documents

    protocol_id = $(this).data( 'protocol-id')
    href = '/documents/bulk_download.zip?protocol_id=' + protocol_id #build the paramaters to the url

    for id in document_ids
      href += "&document_ids[]=" + id

    $('.download-documents').attr("href", href)

