# Copyright © 2011 MUSC Foundation for Research Development
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

$ ->

  # DOCUMENTS LISTENERS BEGIN

  $(document).on 'click', '#document_new', ->
    data = 'sub_service_request_id': $(this).data('sub-service-request-id')
    $.ajax
      type: 'GET'
      url: '/dashboard/documents/new'
      data: data

  $(document).on 'click', '.document_edit', ->
    row_index   = $(this).parents('tr').data('index')
    document_id = $(this).parents('table.documents_table').bootstrapTable('getData')[row_index].id
    data = 'sub_service_request_id': $('#document_new').data('sub-service-request-id')
    $.ajax
      type: 'GET'
      url: "/dashboard/documents/#{document_id}/edit"
      data: data

  $(document).on 'click', '.document_delete', ->
    row_index   = $(this).parents('tr').data('index')
    document_id = $(this).parents('table.documents_table').bootstrapTable('getData')[row_index].id
    data = 'sub_service_request_id': $('#document_new').data('sub-service-request-id')
    if confirm "Are you sure you want to delete the selected Document from this SubServiceRequest?"
      $.ajax
        type: 'DELETE'
        url: "/dashboard/documents/#{document_id}"
        data: data

  $(document).on 'change', '#document_doc_type', ->
    if $(this).val() == 'other'
      $('#doc_type_other_field').show()
    else
      $('#doc_type_other_field').hide()

  # DOCUMENTS LISTENERS END
