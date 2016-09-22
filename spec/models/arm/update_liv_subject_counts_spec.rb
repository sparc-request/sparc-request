# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

require 'rails_helper'

RSpec.describe Arm, type: :model do
  let!(:arm) { create(:arm, subject_count: 3) }
  let!(:liv) { create(:line_items_visit, line_item: li, arm: arm, subject_count: nil) }

  shared_examples_for 'change LineItemsVisit\'s subject_count' do
    it 'should set LineItemsVisit\'s subject_count to Arm\'s subject_count' do
      expect { arm.reload.update_liv_subject_counts }.to change { liv.reload.subject_count }.from(nil).to(3)
    end
  end

  describe '#update_liv_subject_counts' do
    context 'LineItemsVisit belongs to a ServiceRequest in \'draft\' status' do
      let!(:sr)  { create(:service_request_without_validations, status: 'draft') }
      let!(:li)  { create(:line_item_with_service, service_request: sr) }

      it_behaves_like 'change LineItemsVisit\'s subject_count'
    end

    context 'LineItemsVisit belongs to a ServiceRequest in \'first_draft\' status' do
      let!(:sr)  { create(:service_request_without_validations, status: 'first_draft') }
      let!(:li)  { create(:line_item_with_service, service_request: sr) }

      it_behaves_like 'change LineItemsVisit\'s subject_count'
    end

    context 'LineItemsVisit belongs to a ServiceRequest in nil status' do
      let!(:sr)  { create(:service_request_without_validations, status: nil) }
      let!(:li)  { create(:line_item_with_service, service_request: sr) }
      let!(:liv) { create(:line_items_visit, line_item: li, arm: arm, subject_count: nil) }

      it_behaves_like 'change LineItemsVisit\'s subject_count'
    end

    context 'LineItemsVisit belongs to a ServiceRequest not in either \'draft\', \'first_draft\', nor nil status' do
      let!(:sr)  { create(:service_request_without_validations, status: 'sparc') }
      let!(:li)  { create(:line_item_with_service, service_request: sr) }

      it 'should set LineItemsVisit\'s subject_count to Arm\'s subject_count' do
        expect { arm.reload.update_liv_subject_counts }.not_to change { liv.reload.subject_count }
      end
    end
  end
end
