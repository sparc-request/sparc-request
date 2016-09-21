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

RSpec.describe 'Catalog' do
  context "providers and programs with valid pricing setups" do
    let!(:institution)             { create(:institution) }
    let!(:provider1)               { create(:provider, parent_id: institution.id) }
    let!(:provider2)               { create(:provider, parent_id: institution.id) }
    let!(:provider_pricing_setup1) { create(:pricing_setup, organization_id: provider1.id) }
    let!(:program1)                { create(:program, parent_id: provider1.id) }
    let!(:program2)                { create(:program, parent_id: provider2.id) }
    let!(:program_pricing_setup1)  { create(:pricing_setup, organization_id: program1.id) }
    let!(:program_pricing_setup2)  { create(:pricing_setup, organization_id: program2.id) }

    describe "providers with pricing_setups" do
      it "should be able to validate that pricing_setups are correct" do
        allow(Provider).to receive(:all).and_return([provider1])
        allow_message_expectations_on_nil
        allow(@user).to receive(:can_edit_entity?).and_return(true)
        expect(Catalog.invalid_pricing_setups_for(@user)).to be_empty
      end
    end

    describe "providers without pricing_setups and programs with pricing_setups" do
      it "should be able to validate that pricing_setups are correct" do
        allow(Provider).to receive(:all).and_return([provider1, provider2])
        allow_message_expectations_on_nil
        allow(@user).to receive(:can_edit_entity?).and_return(true)
        expect(Catalog.invalid_pricing_setups_for(@user)).to be_empty
      end
    end
  end

  context "providers and programs without valid pricing setups" do
    let!(:institution)             { create(:institution) }
    let!(:provider3)               { create(:provider, parent_id: institution.id) }
    let!(:provider4)               { create(:provider, parent_id: institution.id) }
    let!(:program3)                { create(:program, parent_id: provider3.id) }
    let!(:program4)                { create(:program, parent_id: provider4.id) }
    let!(:provider_pricing_setup3) { create(:pricing_setup, organization_id: provider3.id) }
    let!(:program_pricing_setup3)  { create(:pricing_setup, organization_id: program3.id) }

    describe "mixed provider/program pricing_setups" do
      it "should be able to validate that pricing_setups are incorrect" do
        allow(Provider).to receive(:all).and_return([provider3, provider4])
        allow_message_expectations_on_nil
        allow(@user).to receive(:can_edit_entity?).and_return(true)
        expect(Catalog.invalid_pricing_setups_for(@user)).not_to be_empty
      end
    end
  end
end
