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

require 'date'
require 'rails_helper'

RSpec.describe Program do
 describe "has_pricing_setup" do
    context 'neither program nor parent provider has a pricing setup' do
      it 'should return false' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        expect(program.has_active_pricing_setup).to eq(false)
      end
    end

    context 'program has a pricing setup' do
      it 'should return true' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup

        expect(program.has_active_pricing_setup).to eq(true)
      end
    end

    context 'program has a future pricing setup' do
      it 'should return true' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup

        expect(program.has_active_pricing_setup).to eq(false)
      end
    end

    context 'provider has a pricing setup' do
      it 'should return true' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup

        expect(program.has_active_pricing_setup).to eq(true)
      end
    end

    context 'provider has a future pricing setup' do
      it 'should return true' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup

        expect(program.has_active_pricing_setup).to eq(false)
      end
    end

    context 'provider and program both have a pricing setup' do
      it 'should return true' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup

        expect(program.has_active_pricing_setup).to eq(true)
      end
    end

    context 'provider and program both have a future pricing setup' do
      it 'should return true' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup

        expect(program.has_active_pricing_setup).to eq(false)
      end
    end

    context 'provider has a future and program has an active pricing setup' do
      it 'should return true' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup

        pricing_setup = create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup

        expect(program.has_active_pricing_setup).to eq(true)
      end
    end

    context 'provider has an active and program has a future pricing setup' do
      it 'should return true' do
        provider = create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)
        program = create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = create(:pricing_setup, display_date: Date.today, effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup

        pricing_setup = create(:pricing_setup, display_date: Date.today, effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup

        expect(program.has_active_pricing_setup).to eq(true)
      end
    end
  end
end
