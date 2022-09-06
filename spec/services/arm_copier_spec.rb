# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

require "rails_helper"

RSpec.describe ArmCopier, type: :model do
	describe '#call' do
    let(:protocol)   { create(:protocol_without_validations) }
    let(:copied_arm) { create(:arm, protocol: protocol, visit_count: 3, subject_count: 5) }
    let(:new_arm)    { create(:arm, protocol: protocol, visit_count: 1, subject_count: 1) }

    it 'copies the given arm with all visit groups' do
    	expect { ArmCopier.call(new_arm, copied_arm) }.to change { new_arm.visit_groups.count }.from(1).to(3)
    end

    it 'copies the given arm info to the new arm' do
    	expect { ArmCopier.call(new_arm, copied_arm) }.to change { new_arm.subject_count }.from(1).to(5)
    end

    it 'copies over visit info (quantity types, etc) to the new visits' do
    	Visit.create(quantity: 1, research_billing_qty: 1, visit_group_id: copied_arm.visit_groups.first.id)
    	Visit.create(quantity: 0, research_billing_qty: 0, visit_group_id: new_arm.visit_groups.first.id)
    	expect { ArmCopier.call(new_arm, copied_arm) }.to change { new_arm.visit_groups.first.visits.first.research_billing_qty}.from(0).to(1)
    end
  end
end
