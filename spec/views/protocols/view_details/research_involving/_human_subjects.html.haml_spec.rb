# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

RSpec.describe 'protocols/view_details/research_involving/human_subjects', type: :view do
  context 'with IRB Records' do
    let!(:protocol)   { create(:study_federally_funded, human_subjects: true, with_irb: true) }
    let!(:second_irb) { create(:irb_record, human_subjects_info: protocol.human_subjects_info) }

    it 'should display IRBs with correct contextual classes' do
      render 'protocols/view_details/research_involving/human_subjects', protocol: protocol

      expect(response).to have_content(HumanSubjectsInfo.human_attribute_name(:irb_records))
      expect(response).to have_selector('tr.alert-success', count: 1)
      expect(response).to have_content(protocol.irb_records.first.pro_number)
      expect(response).to have_selector('tr.alert-info', count: 1)
      expect(response).to have_content(protocol.irb_records.last.pro_number)
    end
  end

  context 'without IRB Records' do
    let!(:protocol) { create(:study_federally_funded, human_subjects: true, with_irb: false) }

    it 'should not display any IRB information' do
      render 'protocols/view_details/research_involving/human_subjects', protocol: protocol

      expect(response).to_not have_content(HumanSubjectsInfo.human_attribute_name(:irb_records))
    end
  end
end
