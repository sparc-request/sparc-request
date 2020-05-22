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

require 'rails_helper'

RSpec.describe 'irb_records/irb_record', type: :view do
  let!(:irb) { build(:irb_record) }

  it 'should render hidden fields with the given record index' do
    render 'irb_records/irb_record', irb_record: irb, primary: 'true', index: 0

    expect(response).to have_selector('#protocol_human_subjects_info_attributes_irb_records_attributes_0_pro_number', visible: false)
  end

  context 'primary IRB' do
    it 'should have the success contextual class' do
      render 'irb_records/irb_record', irb_record: irb, primary: 'true', index: 0

      expect(response).to have_selector('.irb-record.list-group-item-success.primary-irb')
    end
  end

  context 'secondary IRB' do
    it 'should have the info contextual class' do
      render 'irb_records/irb_record', irb_record: irb, primary: 'false', index: 0

      expect(response).to have_selector('.irb-record.list-group-item-info:not(.primary-irb)')
    end
  end
end
