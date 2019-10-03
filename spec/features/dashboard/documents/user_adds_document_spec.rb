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

require 'rails_helper'

RSpec.feature 'User wants to add a document', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @protocol       = create(:study_federally_funded, primary_pi: jug2)
    organization    = create(:organization)
    service_request = create(:service_request_without_validations, protocol: @protocol)
                      create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft', protocol: @protocol)

    visit dashboard_protocol_path(@protocol)
    wait_for_javascript_to_finish
  end

  it 'should add the new document' do
    click_link I18n.t('documents.new')
    wait_for_javascript_to_finish

    bootstrap_select '#document_doc_type', 'Budget'
    attach_file 'document_document', File.expand_path('spec/fixtures/files/text_document.txt'), make_visible: true

    click_button I18n.t('actions.upload')
    wait_for_javascript_to_finish

    expect(@protocol.reload.documents.count).to eq(1)
    expect(@protocol.documents.first.doc_type).to eq('budget')
    expect(@protocol.documents.first.sub_service_requests.to_a).to eq([@protocol.sub_service_requests.first])
  end
end
