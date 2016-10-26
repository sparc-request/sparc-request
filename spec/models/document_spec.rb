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

require 'rails_helper'

RSpec.describe Document do
  it { should belong_to(:protocol) }
  it { should have_and_belong_to_many(:sub_service_requests) }

  it 'should create a document' do
    doc = Document.create()
    expect(doc).to be_an_instance_of Document
  end

  describe 'display_document_type' do
    let!(:document1) { create(:document, doc_type: 'other', doc_type_other: 'support') }
    let!(:document2) { create(:document, doc_type: 'hipaa') }

    it 'should display correctly for doc type other' do
      expect(document1.display_document_type).to eq('Support')
    end

    it 'should display correctly for typical doc type' do
      expect(document2.display_document_type).to eq('HIPAA')
    end
  end

  describe '#all_organizations' do
    it 'should return SSR organizations and their trees' do
      document = create(:document)
      org1     = create(:organization)
      org2     = create(:organization, parent: org1)
      ssr1     = create(:sub_service_request_without_validations, organization: org1)
      ssr2     = create(:sub_service_request_without_validations, organization: org2)
      
      document.sub_service_requests = [ssr1, ssr2]

      expect(document.reload.all_organizations).to eq([org1, org2])
    end
  end
end
