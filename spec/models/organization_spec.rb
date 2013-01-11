require 'date'
require 'spec_helper'

describe 'Organization' do
  describe 'parent' do
    it "should return nil if there is no parent" do
      organization = FactoryGirl.build(:organization)
      organization.save!
      organization.parent.should equal nil
    end

    it "should return the parent if there is a parent" do
      parent = FactoryGirl.build(:organization)
      parent.save!

      child = FactoryGirl.build(:organization, :parent_id => parent.id)
      child.save!

      child.parent.should eq parent
    end
  end

  describe 'parents' do
    it 'should return an empty array if there is no parent' do
      organization = FactoryGirl.build(:organization)
      organization.save!
      organization.parents.should eq []
    end

    it 'should return a single parent if it has a parent and the parent has no parent' do
      parent = FactoryGirl.build(:organization)
      parent.save!

      child = FactoryGirl.build(:organization, :parent_id => parent.id)
      child.save!

      child.parents.should eq [ parent ]
    end

    it 'should return the parent and grandparent if there is a grandparent' do
      grandparent = FactoryGirl.build(:organization)
      grandparent.save!

      parent = FactoryGirl.build(:organization, :parent_id => grandparent.id)
      parent.save!

      child = FactoryGirl.build(:organization, :parent_id => parent.id)
      child.save!

      child.parents.should eq [ parent, grandparent ]
    end
  end

  describe 'heirarchy methods' do 

    let!(:institution) { FactoryGirl.create(:institution) }
    let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
    let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
    let!(:program2) { FactoryGirl.create(:program, parent_id: provider.id) }
    let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }
    let!(:core2) { FactoryGirl.create(:core, parent_id: program2.id) }
    

    describe 'process ssrs parent' do
               
      it 'should return the core if process ssrs is set to true' do
        core.process_ssrs = true
        core.save
        core.process_ssrs_parent.should eq(core)
      end

      it 'should return the program if process ssrs is on the program' do
        program.process_ssrs = true
        program.save
        core.process_ssrs_parent.should eq(program)     
      end

      it 'should return the program if process ssrs is on the provider and the program' do
        program.process_ssrs = true
        program.save
        provider.process_ssrs = true
        provider.save
        core.process_ssrs_parent.should eq(program)
      end

      it 'should return the correct program if process ssrs is set on multiple programs' do
        program.process_ssrs = true
        program.save
        program2.process_ssrs = true
        program2.save
        core.process_ssrs_parent.should eq(program)
        core2.process_ssrs_parent.should eq(program2)
      end
    end

    describe 'children' do

      it 'should return only the provider if it is an institution' do
        institution.children.should include(provider)
        institution.children.should_not include(program)
      end

      it 'should return the program if it is a provider' do 
        provider.children.should include(program)
      end

      it 'should return the core if it is a program' do
        program.children.should include(core)
      end
    end

    describe 'all children' do
      it 'should return itself if it is a core' do
        core.all_children.should eq([core])
      end

      it 'should return the core if it is a program' do
        program.all_children.should include(core)
        program.all_children.should_not include(core2)
      end

      it 'should return multiple programs and cores if it is a provider' do
        provider.all_children.should include(core, core2, program, program2)
      end

      it 'should return everything if it is an institution' do
        institution.all_children.should include(core, core2, program, program2, provider)
      end
    end

    describe 'all child services' do
      let!(:service)  { FactoryGirl.create(:service, organization_id: core.id) }
      let!(:service2) { FactoryGirl.create(:service, organization_id: core2.id) }
      let!(:program3) { FactoryGirl.create(:program, parent_id: provider.id) }
      let!(:service3) { FactoryGirl.create(:service, organization_id: program3.id) }
      let!(:program4) { FactoryGirl.create(:program) }
      let!(:core3)    { FactoryGirl.create(:core, parent_id: program4.id) }

      it 'should return the correct service for a core' do
        core.all_child_services.should eq([service])
      end

      it 'should return the services under a program with cores' do
        program.all_child_services.should eq([service])
      end

      it 'should return the services under a program without cores' do
        program3.all_child_services.should eq([service3])
      end

      it 'should return the services under a program that offers both services and cores' do
        prog = FactoryGirl.create(:program)
        prog_core = FactoryGirl.create(:core, parent_id: prog.id)
        serv1 = FactoryGirl.create(:service, organization_id: prog.id)
        serv2 = FactoryGirl.create(:service, organization_id: prog_core.id)
        prog.all_child_services.should include(serv1, serv2)
      end

      it 'should return the services under a provider' do
        provider.all_child_services.should include(service, service2, service3)
      end

      it 'should return the services under an institution' do
        institution.all_child_services.should include(service, service2, service3)
      end
    end
  end


  describe 'current_pricing_setup' do
    it 'should raise an exception if there are no pricing setups' do
      organization = FactoryGirl.build(:provider)
      organization.save!
      lambda { organization.current_pricing_setup }.should raise_exception(ArgumentError)
    end

    it 'should return the only pricing setup if there is one pricing setup and it is in the past' do
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 1)
      organization.pricing_setups[0].display_date = Date.today - 1
      organization.current_pricing_setup.should eq organization.pricing_setups[0]
    end

    it 'should return the most recent pricing setup in the past if there is more than one' do
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 2)
      organization.pricing_setups[0].display_date = Date.today - 1
      organization.pricing_setups[1].display_date = Date.today - 2
      organization.current_pricing_setup.should eq organization.pricing_setups[0]
    end

    it 'should return the most recent pricing setup in the past if there is more than one and the order is reversed' do
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 2)
      organization.pricing_setups[0].display_date = Date.today - 2
      organization.pricing_setups[1].display_date = Date.today - 1
      organization.current_pricing_setup.should eq organization.pricing_setups[1]
    end

    it 'should return the pricing setup in the past if one is in the past and one is in the future' do
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 2)
      organization.pricing_setups[0].display_date = Date.today - 1
      organization.pricing_setups[1].display_date = Date.today + 1
      organization.current_pricing_setup.should eq organization.pricing_setups[0]
    end

    it 'should return the pricing setup in the past if one is in the past and one is in the future and the order is reversed' do
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 2)
      organization.pricing_setups[0].display_date = Date.today + 1
      organization.pricing_setups[1].display_date = Date.today - 1
      organization.current_pricing_setup.should eq organization.pricing_setups[1]
    end

    it 'should return the pricing setup for today if there is a pricing setup with a display date of today' do
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 3)
      organization.pricing_setups[0].display_date = Date.today + 1
      organization.pricing_setups[1].display_date = Date.today
      organization.pricing_setups[2].display_date = Date.today - 1
      organization.current_pricing_setup.should eq organization.pricing_setups[1]
    end
  end

  describe 'pricing_setup_for_date' do
    it 'should raise an exception if there are no pricing setups' do
      organization = FactoryGirl.create(:provider)
      lambda { organization.pricing_setup_for_date(Date.parse('2012-01-01')) }.should raise_exception(ArgumentError)
    end

    it 'should return the pricing setup for the given date if there is a pricing setup with a display date of that date' do
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 5)
      base_date = Date.parse('2012-01-01')
      organization.pricing_setups[0].display_date = base_date + 1
      organization.pricing_setups[1].display_date = base_date
      organization.pricing_setups[2].display_date = base_date - 1
      organization.pricing_setups[3].display_date = base_date - 2
      organization.pricing_setups[4].display_date = base_date - 3
      organization.pricing_setup_for_date(base_date).should eq organization.pricing_setups[1]
    end

    # most of these tests would be duplicates of those for
    # current_pricing_setup
  end

  describe 'eligible_for_subsidy?' do
    it 'should return false if there is no subsidy map' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(nil)
      organization.eligible_for_subsidy?.should eq false
    end

    it 'should return true if max dollar cap is greater than 0' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(double(
          max_dollar_cap: 1,
          max_percentage: 0))
      organization.eligible_for_subsidy?.should eq true
    end

    it 'should return true if max percentage is greater than 0' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(double(
          max_dollar_cap: 0,
          max_percentage: 1))
      organization.eligible_for_subsidy?.should eq true
    end

    it 'should return false if max dollar cap is 0 and max percentage is 0' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(double(
          max_dollar_cap: 0,
          max_percentage: 0))
      organization.eligible_for_subsidy?.should eq false
    end

    it 'should return false if max dollar cap is nil and subsidy map is 0' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(double(
          max_dollar_cap: nil,
          max_percentage: 0))
      organization.eligible_for_subsidy?.should eq false
    end

    it 'should return false if max dollar cap is 0 and subsidy map is nil' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(double(
          max_dollar_cap: 0,
          max_percentage: nil))
      organization.eligible_for_subsidy?.should eq false
    end

    it 'should return true if max dollar cap is nil and subsidy map is 1' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(double(
          max_dollar_cap: nil,
          max_percentage: 1))
      organization.eligible_for_subsidy?.should eq true
    end

    it 'should return true if max dollar cap is 1 and subsidy map is nil' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(double(
          max_dollar_cap: 1,
          max_percentage: nil))
      organization.eligible_for_subsidy?.should eq true
    end

    it 'should return false if max dollar cap is nil and subsidy map is nil' do
      organization = FactoryGirl.create(:organization)
      organization.stub(:subsidy_map).and_return(double(
          max_dollar_cap: nil,
          max_percentage: nil))
      organization.eligible_for_subsidy?.should eq false
    end
  end

  describe "relationship methods" do

    let!(:institution)       {FactoryGirl.create(:institution)}
    let!(:institution2)      {FactoryGirl.create(:institution, process_ssrs: true)}
    let!(:provider)          {FactoryGirl.create(:provider, parent_id: institution.id)}
    let!(:provider2)         {FactoryGirl.create(:provider, parent_id: institution2.id)}
    let!(:program)           {FactoryGirl.create(:program, parent_id: provider2.id)}
    let!(:service_provider)  {FactoryGirl.create(:service_provider, identity_id: 1, organization_id: provider.id)}
    let!(:service_provider2) {FactoryGirl.create(:service_provider, identity_id: 2, organization_id: institution2.id)}
    let!(:service_provider3) {FactoryGirl.create(:service_provider, identity_id: 3, organization_id: program.id)}
    let!(:service_provider4) {FactoryGirl.create(:service_provider, identity_id: 4, organization_id: institution.id)}
    let!(:super_user)        {FactoryGirl.create(:super_user, identity_id: 1, organization_id: institution2.id)}
    let!(:super_user2)       {FactoryGirl.create(:super_user, identity_id: 2, organization_id: provider2.id)}
    let!(:super_user3)       {FactoryGirl.create(:super_user, identity_id: 3, organization_id: program.id)}

    describe "service providers lookup" do

      it "should return an organization's service providers if they exist" do
        provider.service_providers_lookup.should eq([service_provider])
      end

      it "should return parent organization's service provider if child organization does not have one" do
        provider2.service_providers_lookup.should eq([service_provider2])
      end
    end

    describe "all service providers" do

      it "should return an organization's own service providers" do
        provider.all_service_providers.should include(service_provider)
      end

      it "should return the parent's service providers" do
        provider.all_service_providers.should include(service_provider4)
      end

      it "should return the child's service providers if process ssrs is set" do
        institution2.all_service_providers.should include(service_provider3)
      end

      it "should not include its own service provider more than once" do
        institution2.all_service_providers.should eq([service_provider3, service_provider2])
      end
    end

    describe "all super users" do

      it "should return an organization's own super users" do
        provider2.all_super_users.should include(super_user2)
      end

      it "should return the parent's super users" do
        provider2.all_super_users.should include(super_user)
      end

      it "should return the child's super users" do
        institution2.all_super_users.should include(super_user3)
      end

      it "should not include its own super user more than once" do
        institution2.all_super_users.should eq([super_user2, super_user3, super_user])
      end
    end
  end
end

