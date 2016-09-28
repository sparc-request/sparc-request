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

RSpec.describe CatalogManager::CatalogHelper do

  context '#disable_pricing_setup' do
    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = create(:pricing_setup)
      expect(helper.disable_pricing_setup(pricing_setup, true)).to eq(false)
    end

    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = create(:pricing_setup, display_date: Date.parse('2018-01-01'))
      expect(helper.disable_pricing_setup(pricing_setup, true)).to eq(false)
    end

    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = create(:pricing_setup, display_date: Date.parse('2018-01-01'))
      expect(helper.disable_pricing_setup(pricing_setup, false)).to eq(true)
    end

    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = create(:pricing_setup, effective_date: Date.parse('2018-01-01'))
      expect(helper.disable_pricing_setup(pricing_setup, true)).to eq(false)
    end

    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = create(:pricing_setup, effective_date: Date.parse('2018-01-01'))
      expect(helper.disable_pricing_setup(pricing_setup, false)).to eq(true)
    end
  end

  context '#disable_pricing_map' do
    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = create(:pricing_map)
      expect(helper.disable_pricing_map(pricing_map, true)).to eq(false)
    end

    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = create(:pricing_map, display_date: Date.parse('2018-01-01'))
      expect(helper.disable_pricing_map(pricing_map, true)).to eq(false)
    end

    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = create(:pricing_map, display_date: Date.parse('2018-01-01'))
      expect(helper.disable_pricing_map(pricing_map, false)).to eq(true)
    end

    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = create(:pricing_setup, effective_date: Date.parse('2018-01-01'))
      expect(helper.disable_pricing_map(pricing_map, true)).to eq(false)
    end

    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = create(:pricing_map, effective_date: Date.parse('2018-01-01'))
      expect(helper.disable_pricing_map(pricing_map, false)).to eq(true)
    end
  end

  context '#disabled_parent' do
    it 'should return the name of the highest disabled organization in the tree' do
      institution = create(:institution, name: 'Institution', is_available: true)
      provider    = create(:provider, name: 'Provider', parent_id: institution.id, is_available: false)
      program     = create(:program, name: 'Program', parent_id: provider.id, is_available: false)
      core        = create(:core, name: 'Core', parent_id: program.id, is_available: false)

      expect(helper.disabled_parent(core)).to eq("Disabled at: #{provider.name}")
    end
  end
end
