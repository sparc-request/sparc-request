require 'date'
require 'spec_helper'

describe Program do
 describe "has_pricing_setup" do   
    context 'neither program nor parent provider has a pricing setup' do
      it 'should return false' do        
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)
        
        expect(program.has_active_pricing_setup).to eq(false)  
      end
    end
    
    context 'program has a pricing setup' do
      it 'should return true' do
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup
        
        expect(program.has_active_pricing_setup).to eq(true)
      end
    end
    
    context 'program has a future pricing setup' do
      it 'should return true' do
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup
        
        expect(program.has_active_pricing_setup).to eq(false)
      end
    end
      
    context 'provider has a pricing setup' do
      it 'should return true' do  
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup
        
        expect(program.has_active_pricing_setup).to eq(true)
      end
    end
    
    context 'provider has a future pricing setup' do
      it 'should return true' do  
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup
        
        expect(program.has_active_pricing_setup).to eq(false)
      end
    end
    
    context 'provider and program both have a pricing setup' do
      it 'should return true' do  
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup
        
        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup
        
        expect(program.has_active_pricing_setup).to eq(true)
      end
    end
    
    context 'provider and program both have a future pricing setup' do
      it 'should return true' do  
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup
        
        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup
        
        expect(program.has_active_pricing_setup).to eq(false)
      end
    end
    
    context 'provider has a future and program has an active pricing setup' do
      it 'should return true' do  
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup
        
        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today,effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup
        
        expect(program.has_active_pricing_setup).to eq(true)
      end
    end
    
    context 'provider has an active and program has a future pricing setup' do
      it 'should return true' do  
        provider = FactoryGirl.create(:provider, name: 'SCTR', order: 1,  abbreviation: 'SCTR1', is_available: 1)    
        program = FactoryGirl.create(:program, type: 'Program', name: 'Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation: 'Informatics', is_available: 1)

        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today, effective_date: Date.today, college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        provider.pricing_setups << pricing_setup
        
        pricing_setup = FactoryGirl.create(:pricing_setup, display_date: Date.today, effective_date: (Date.today + 1), college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type: 'full', internal_rate_type: 'full')
        program.pricing_setups << pricing_setup
        
        expect(program.has_active_pricing_setup).to eq(true)
      end
    end
  end
end
 
