# Copyright © 2011-2019 MUSC Foundation for Research Development
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
#= require cart
#= require forms

$(document).ready ->
  $(document).on 'click', '#document-new', ->
    data =
      protocol_id: $(this).data('protocol-id')
      srid: getSRId()
    $.ajax
      type: 'GET'
      url: '/documents/new'
      data: data
    return false

  $(document).on 'click', '.document-edit', ->
    row_index   = $(this).parents('tr').data('index')
    document_id = $(this).parents('table#documents-table').bootstrapTable('getData')[row_index].id
    $.ajax
      type: 'GET'
      url: "/documents/#{document_id}/edit"
      data:
        srid: getSRId()

  $(document).on 'click', '.document-delete', ->
    row_index   = $(this).parents('tr').data('index')
    document_id = $(this).parents('table#documents-table').bootstrapTable('getData')[row_index].id
    if confirm I18n['documents']['delete_confirm']
      $.ajax
        type: 'DELETE'
        url: "/documents/#{document_id}?srid=#{getSRId()}"

  $(document).on 'change', '#document_doc_type', ->
    if $(this).val() == 'other'
      $('#doc-type-other-field').show()
    else
      $('#doc-type-other-field').hide()
