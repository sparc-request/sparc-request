# Copyright © 2011-2017 MUSC Foundation for Research Development
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

module Dashboard::DocumentsHelper

  def dashboard_display_document_title(document, permission)
    if permission
      link_to document.document_file_name, document.document.url
    else
      document.document_file_name
    end
  end

  def dashboard_document_edit_button(document, permission)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"})
      ), type: 'button', class: "btn btn-warning actions-button document-edit #{permission ? '' : 'disabled'}", data: { permission: permission.to_s }
    )
  end

  def dashboard_document_delete_button(document, permission)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"})
      ), type: 'button', class: "btn btn-danger actions-button document-delete #{permission ? '' : 'disabled'}", data: { permission: permission.to_s }
    )
  end

  def document_org_access_collection(document, action)
    default_select  = if action == 'new'
                        document.protocol.organizations.ids
                      else
                        document.sub_service_requests.map(&:organization_id)
                      end
    options_from_collection_for_select(document.protocol.organizations.distinct.sort_by(&:name), :id, :name, default_select)
  end
end
