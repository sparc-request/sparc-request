require 'spec_helper'

describe CatalogManager::CatalogHelper do

  context :node do
    let(:institution){
      FactoryGirl.create(:institution,
        name:                 'Medical University of South Carolina',
        order:                1,
        obisid:               '87d1220c5abf9f9608121672be000412',
        abbreviation:         'MUSC',
        is_available:         1
      )
    }

    let(:provider){ 
      FactoryGirl.create(:provider,
        name:                 'South Carolina Clinical and Translational Institute (SCTR)',
        order:                1,
        css_class:            'blue-provider',
        obisid:               '87d1220c5abf9f9608121672be0011ff',
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
        obisid:               '87d1220c5abf9f9608121672be021963',
        parent_id:            provider.id,
        abbreviation:         'Informatics',
        process_ssrs:         0,
        is_available:         1
      )
    }
    
    it 'should return a organization node for js.tree' do
      helper.node(institution).should eq "<a href=\"#\" cid=\"#{institution.id}\" class=\"\" object_type=\"institution\">Medical University of South Carolina</a>"
    end

    it 'should return a organization node for js.tree' do
      helper.node(institution, false).should eq "<a href=\"#\" cid=\"#{institution.id}\" class=\"disabled_node\" object_type=\"institution\">Medical University of South Carolina</a>"
    end

    it 'should return a organization node for js.tree' do
      helper.node(provider).should eq "<a href=\"#\" cid=\"#{provider.id}\" class=\"\" object_type=\"provider\">South Carolina Clinical and Translational Institute (SCTR)</a>"
    end

    it 'should return a organization node for js.tree' do
      helper.node(provider, false).should eq "<a href=\"#\" cid=\"#{provider.id}\" class=\"disabled_node\" object_type=\"provider\">South Carolina Clinical and Translational Institute (SCTR)</a>"
    end

    it 'should return a organization node for js.tree' do
      helper.node(program).should eq "<a href=\"#\" cid=\"#{program.id}\" class=\"\" object_type=\"program\">Office of Biomedical Informatics</a>"
    end    

    it 'should return a organization node for js.tree' do
      helper.node(program, false).should eq "<a href=\"#\" cid=\"#{program.id}\" class=\"disabled_node\" object_type=\"program\">Office of Biomedical Informatics</a>"
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

