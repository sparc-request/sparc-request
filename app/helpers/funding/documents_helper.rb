# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module Funding::DocumentsHelper
 
  def display_pi(ssr)
    ssr.protocol.primary_principal_investigator.last_name_first
  end

  def display_pi_institution(ssr)
    ssr.protocol.primary_principal_investigator.try(:professional_org_lookup, 'institution')
  end

  def display_actions(ssr)
    protocol_button(ssr) +
    admin_edit_button(ssr)
  end

  def display_funding_document_title(document)
    link_to document.document_file_name.humanize, document.document.url, download: document.document_file_name.humanize, 'data-toggle' => 'tooltip', 'data-placement' => 'right'
  end

  private

  def protocol_button(ssr)
    link_to t(:funding)[:download][:table][:actions][:protocol], "/dashboard/protocols/#{ssr.protocol.id}", class: "btn btn-success btn-sm protocol-btn", target: :blank  
  end

  def admin_edit_button(ssr)
    link_to t(:funding)[:download][:table][:actions][:admin_edit], "/dashboard/sub_service_requests/#{ssr.id}", class: "btn btn-warning btn-sm admin-edit-btn", target: :blank
  end

end
