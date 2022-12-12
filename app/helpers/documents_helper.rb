# Copyright © 2011-2022 MUSC Foundation for Research Development
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

module DocumentsHelper
  def new_document_button(opts={})
    unless in_dashboard? && !opts[:permission]
      url = in_dashboard? ? new_dashboard_document_path(protocol_id: opts[:protocol_id]) : new_document_path(srid: opts[:srid])

      link_to url, remote: true, class: 'btn btn-success', title: t('documents.tooltips.new'), data: { toggle: 'tooltip' } do
        icon('fas', 'plus mr-2') + t('documents.new')
      end
    end
  end

  def display_document_title(document, opts={})
    if document.document.attached?
      if in_dashboard? && !opts[:permission]
        document.document.filename
      else
        link_to document.document.filename, rails_blob_path(document.document, disposition: 'attachment'), target: :_blank
      end
    end
  end

  def display_document_providers(document)
    if document.share_all?
      t('documents.table.all_providers', protocol_type: document.protocol.model_name.human)
    else
      organizations = document.organizations.uniq

      if organizations.length > 3
        link_to 'javascript:void(0)', data: { toggle: 'popover', trigger: 'hover', boundary: 'window', html: 'true', content: organizations.map(&:name).join('<br>') } do
          t('documents.table.providers', provider_count: organizations.length)
        end
      else
        organizations.map(&:name).join('<br>')
      end
    end
  end

  def document_actions(document, opts={})
    content_tag :div, class: 'd-flex justify-content-center' do
      raw([
        edit_document_button(document, opts),
        delete_document_button(document, opts)
      ].join(''))
    end
  end

  def edit_document_button(document, opts={})
    unless in_dashboard? && !opts[:permission]
      url = in_dashboard? ? edit_dashboard_document_path(document) : edit_document_path(document, srid: opts[:srid])

      link_to icon('far', 'edit'), url, remote: true, class: "btn btn-warning mr-1 edit-document"
    end
  end

  def delete_document_button(document, opts={})
    unless in_dashboard? && !opts[:permission]
      url = in_dashboard? ? dashboard_document_path(document) : document_path(document, srid: opts[:srid])

      link_to icon('fas', 'trash-alt'), url, method: :delete, remote: true, class: "btn btn-danger delete-document", data: { confirm_swal: 'true' }
    end
  end

  def document_file_types_as_string
    Document::SUPPORTED_FILE_TYPES.map(&:source).map{ |d| d.gsub('\\', '').gsub('$', '').gsub('?', '') }.join(' ')
  end

  def display_check_box(document)
    check_box_tag "select-document-#{document.id}", "#{document.id}"
  end

end
