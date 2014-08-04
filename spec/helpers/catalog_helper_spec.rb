# Copyright © 2011 MUSC Foundation for Research Development
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

require 'spec_helper'

describe CatalogManager::CatalogHelper do

  context :node do
    let(:institution){
      FactoryGirl.create(:institution,
        name:                 'Medical University of South Carolina',
        order:                1,
        abbreviation:         'MUSC',
        is_available:         1
      )
    }

    let(:provider){ 
      FactoryGirl.create(:provider,
        name:                 'South Carolina Clinical and Translational Institute (SCTR)',
        order:                1,
        css_class:            'blue-provider',
        parent_id:            institution.id,
        abbreviation:         'SCTR1',
        process_ssrs:         0,
        is_available:         1
      )
    }

    let(:program){
      FactoryGirl.create(:program,
        type:                 'Program',
        name:                 'Office of Biomedical Informatics',
        order:                1,
        description:          'The Biomedical Informatics Programs goal is to integrate..',
        parent_id:            provider.id,
        abbreviation:         'Informatics',
        process_ssrs:         0,
        is_available:         1
      )
    }
    
    it 'should return a organization node for js.tree' do
      helper.node(institution).should eq "<a href=\"#\" cid=\"#{institution.id}\" class=\"institution\" object_type=\"institution\">Medical University of South Carolina</a>"
    end

    it 'should return a organization node for js.tree' do
      helper.node(institution, false).should eq "<a href=\"#\" cid=\"#{institution.id}\" class=\"institution disabled_node\" object_type=\"institution\">Medical University of South Carolina</a>"
    end

    it 'should return a organization node for js.tree' do
      helper.node(provider).should eq "<a href=\"#\" cid=\"#{provider.id}\" class=\"provider\" object_type=\"provider\">South Carolina Clinical and Translational Institute (SCTR)</a>"
    end

    it 'should return a organization node for js.tree' do
      helper.node(provider, false).should eq "<a href=\"#\" cid=\"#{provider.id}\" class=\"provider disabled_node\" object_type=\"provider\">South Carolina Clinical and Translational Institute (SCTR)</a>"
    end

    it 'should return a organization node for js.tree' do
      helper.node(program).should eq "<a href=\"#\" cid=\"#{program.id}\" class=\"program\" object_type=\"program\">Office of Biomedical Informatics</a>"
    end    

    it 'should return a organization node for js.tree' do
      helper.node(program, false).should eq "<a href=\"#\" cid=\"#{program.id}\" class=\"program disabled_node\" object_type=\"program\">Office of Biomedical Informatics</a>"
    end
  end
  
  context :disable_pricing_setup do
    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = FactoryGirl.create(:pricing_setup)
      helper.disable_pricing_setup(pricing_setup, true).should eq(false)
    end

    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = FactoryGirl.create(:pricing_setup, :display_date => Date.parse('2018-01-01'))
      helper.disable_pricing_setup(pricing_setup, true).should eq(false)
    end

    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = FactoryGirl.create(:pricing_setup, :display_date => Date.parse('2018-01-01'))
      helper.disable_pricing_setup(pricing_setup, false).should eq(true)
    end

    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = FactoryGirl.create(:pricing_setup, :effective_date => Date.parse('2018-01-01'))
      helper.disable_pricing_setup(pricing_setup, true).should eq(false)
    end

    it "should return whether or not it can edit a pricing setup based on date" do
      pricing_setup = FactoryGirl.create(:pricing_setup, :effective_date => Date.parse('2018-01-01'))
      helper.disable_pricing_setup(pricing_setup, false).should eq(true)
    end
  end
  
  context :disable_pricing_map do
    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = FactoryGirl.create(:pricing_map)
      helper.disable_pricing_map(pricing_map, true).should eq(false)
    end

    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = FactoryGirl.create(:pricing_map, :display_date => Date.parse('2018-01-01'))
      helper.disable_pricing_map(pricing_map, true).should eq(false)
    end

    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = FactoryGirl.create(:pricing_map, :display_date => Date.parse('2018-01-01'))
      helper.disable_pricing_map(pricing_map, false).should eq(true)
    end

    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = FactoryGirl.create(:pricing_setup, :effective_date => Date.parse('2018-01-01'))
      helper.disable_pricing_map(pricing_map, true).should eq(false)
    end

    it "should return whether or not it can edit a pricing map based on date" do
      pricing_map = FactoryGirl.create(:pricing_map, :effective_date => Date.parse('2018-01-01'))
      helper.disable_pricing_map(pricing_map, false).should eq(true)
    end
  end
  
end

