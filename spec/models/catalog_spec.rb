require 'spec_helper'

describe 'Catalog' do
  context "providers and programs with valid pricing setups" do
    let!(:institution) { FactoryGirl.create(:institution) }
    let!(:provider1) { FactoryGirl.create(:provider, parent_id: institution.id) }
    let!(:provider2) { FactoryGirl.create(:provider, parent_id: institution.id) }  
    let!(:provider_pricing_setup1) { FactoryGirl.create(:pricing_setup, organization_id: provider1.id) }
    let!(:program1) { FactoryGirl.create(:program, parent_id: provider1.id) }
    let!(:program2) { FactoryGirl.create(:program, parent_id: provider2.id) }
    let!(:program_pricing_setup1) { FactoryGirl.create(:pricing_setup, organization_id: program1.id) }
    let!(:program_pricing_setup2) { FactoryGirl.create(:pricing_setup, organization_id: program2.id) }

    describe "providers with pricing_setups" do
      it "should be able to validate that pricing_setups are correct" do
        Provider.stub!(:provider).and_return(provider1) 
        allow_message_expectations_on_nil    
        @user.stub!(:can_edit_entity?).and_return(true)
        Catalog.invalid_pricing_setups_for(@user).should be_empty
      end
    end

    describe "providers without pricing_setups and programs with pricing_setups" do
      it "should be able to validate that pricing_setups are correct" do
        Provider.stub!(:all).and_return([provider1, provider2])
        allow_message_expectations_on_nil 
        @user.stub!(:can_edit_entity?).and_return(true)
        Catalog.invalid_pricing_setups_for(@user).should be_empty
      end
    end
  end
  
  context "providers and programs without valid pricing setups" do  
    let!(:institution) { FactoryGirl.create(:institution) }    
    let!(:provider3) { FactoryGirl.create(:provider, parent_id: institution.id) }
    let!(:provider4) { FactoryGirl.create(:provider, parent_id: institution.id) }  
    let!(:program3) { FactoryGirl.create(:program, parent_id: provider3.id) }
    let!(:program4) { FactoryGirl.create(:program, parent_id: provider4.id) }
    let!(:provider_pricing_setup3) { FactoryGirl.create(:pricing_setup, organization_id: provider3.id) }
    let!(:program_pricing_setup3) { FactoryGirl.create(:pricing_setup, organization_id: program3.id) }  
    
    describe "mixed provider/program pricing_setups" do    
      it "should be able to validate that pricing_setups are incorrect" do
        Provider.stub!(:all).and_return([provider3, provider4])
        allow_message_expectations_on_nil 
        @user.stub!(:can_edit_entity?).and_return(true)
        Catalog.invalid_pricing_setups_for(@user).should_not be_empty
      end
    end
  end

end

