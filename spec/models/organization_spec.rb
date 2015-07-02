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

require 'date'
require 'spec_helper'

describe 'organization' do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  describe 'submission emails lookup' do

      let!(:submission_email_1) {FactoryGirl.create(:submission_email, organization_id: provider.id)}
      let!(:submission_email_2) {FactoryGirl.create(:submission_email, organization_id: program.id)}
      let!(:submission_email_3) {FactoryGirl.create(:submission_email, organization_id: core.id)}

      before :each do
        provider.update_attributes(process_ssrs: 1)
        core.update_attributes(process_ssrs: 1)
        sub_service_request.update_attributes(organization_id: core.id)
      end

      it "should return the first submission e-mails it finds" do
        sub_service_request.organization.submission_emails_lookup.should include(submission_email_3)
        core.submission_emails.delete_all
        sub_service_request.reload
        sub_service_request.organization.submission_emails_lookup.should include(submission_email_2)
        program.submission_emails.delete_all
        sub_service_request.reload
        sub_service_request.organization.submission_emails_lookup.should include(submission_email_1)

        # now let's add the core back
        submission_email_4 = core.submission_emails.create(:email => submission_email_3.email)
        core.save!
        sub_service_request.reload
        sub_service_request.organization.submission_emails_lookup.should include(submission_email_4)
      end
  end

  describe 'parent' do

    it "should return nil if there is no parent" do
     institution.parent.should equal nil
    end

    it "should return the parent if there is a parent" do
      provider.parent.should eq institution
    end
  end

  describe 'parents' do

    it 'should return an empty array if there is no parent' do
      institution.parents.should eq []
    end

    it 'should return a single parent if it has a parent and the parent has no parent' do
      provider.parents.should eq [ institution ]
    end

    it 'should return the parent and grandparent if there is a grandparent' do
      program.parents.should eq [ provider, institution ]
    end
  end

  describe 'heirarchy methods' do

    let!(:program2) { FactoryGirl.create(:program, parent_id: provider.id) }
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
        institution.children(Organization.all).should include(provider)
        institution.children(Organization.all).should_not include(program)
      end

      it 'should return the program if it is a provider' do
        provider.children(Organization.all).should include(program)
      end

      it 'should return the core if it is a program' do
        program.children(Organization.all).should include(core)
      end
    end

    describe 'all children' do

      it 'should return itself if it is a core' do
        core.all_children(Organization.all).should eq([core])
      end

      it 'should return the core if it is a program' do
        program.all_children(Organization.all).should include(core)
        program.all_children(Organization.all).should_not include(core2)
      end

      it 'should return multiple programs and cores if it is a provider' do
        provider.all_children(Organization.all).should include(core, core2, program, program2)
      end

      it 'should return everything if it is an institution' do
        institution.all_children(Organization.all).should include(core, core2, program, program2, provider)
      end
    end

    describe 'service providers for services' do

      let!(:provider_organization)       { FactoryGirl.create(:provider) }
      let!(:program_organization)        { FactoryGirl.create(:program, parent_id: provider_organization.id) }
      let!(:core_organization)           { FactoryGirl.create(:core, parent_id: program_organization.id) }
      let!(:program_service)             { FactoryGirl.create(:service, organization_id: program_organization.id) }
      let!(:core_service)                { FactoryGirl.create(:service, organization_id: core_organization.id) }

      it "should return true if a service has a service provider in the tree" do
        service_provider = FactoryGirl.create(:service_provider, organization_id: provider_organization.id)
        program_organization.service_providers_for_child_services?.should eq(true)
      end

      it "should return false if a service does not have a service provider in the tree" do
        program_organization.service_providers_for_child_services?.should eq(false)
      end

      it "should return false if there is a service provider, but it's only on the current organization" do
        service_provider = FactoryGirl.create(:service_provider, organization_id: program_organization.id)
        program_organization.service_providers_for_child_services?.should eq(false)
      end
    end

    describe 'all child services' do

      let!(:service2) { FactoryGirl.create(:service, organization_id: core2.id) }
      let!(:program3) { FactoryGirl.create(:program, parent_id: provider.id) }
      let!(:service3) { FactoryGirl.create(:service, organization_id: program3.id) }
      let!(:program4) { FactoryGirl.create(:program) }
      let!(:core3)    { FactoryGirl.create(:core, parent_id: program4.id) }

      before :each do
        service.update_attributes(organization_id: core.id)
      end

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

  describe 'pricing setup for date' do

    it 'should raise an exception if there are no pricing setups' do
      organization = FactoryGirl.create(:provider)
      lambda { organization.pricing_setup_for_date(Date.parse('2012-01-01')) }.should raise_exception(ArgumentError)
    end

    it 'should return the displayed pricing setup for the given date if there is a pricing setup with a display date of that date' do
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

  describe 'effective pricing setup for date' do

    it 'should return the pricing setup that is effective on a given date' do
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 5)
      organization = FactoryGirl.build(:provider, :pricing_setup_count => 5)
      base_date = Date.parse('2012-01-01')
      organization.pricing_setups[0].display_date = base_date + 1
      organization.pricing_setups[1].display_date = base_date
      organization.pricing_setups[2].display_date = base_date - 1
      organization.pricing_setups[3].display_date = base_date - 2
      organization.pricing_setups[4].display_date = base_date - 3
      organization.pricing_setup_for_date(base_date).should eq organization.pricing_setups[1]
    end
  end

  describe 'eligible for subsidy?' do

    it 'should return false if there is no subsidy map' do
      program.stub(:subsidy_map).and_return(nil)
      program.eligible_for_subsidy?.should eq false
    end

    it 'should return true if max dollar cap is greater than 0' do
      program.stub(:subsidy_map).and_return(double(max_dollar_cap: 1, max_percentage: 0))
      program.eligible_for_subsidy?.should eq true
    end

    it 'should return true if max percentage is greater than 0' do
      program.stub(:subsidy_map).and_return(double(max_dollar_cap: 0, max_percentage: 1))
      program.eligible_for_subsidy?.should eq true
    end

    it 'should return false if max dollar cap is 0 and max percentage is 0' do
      program.stub(:subsidy_map).and_return(double(max_dollar_cap: 0, max_percentage: 0))
      program.eligible_for_subsidy?.should eq false
    end

    it 'should return false if max dollar cap is nil and subsidy map is 0' do
      program.stub(:subsidy_map).and_return(double(max_dollar_cap: nil, max_percentage: 0))
      program.eligible_for_subsidy?.should eq false
    end

    it 'should return false if max dollar cap is 0 and subsidy map is nil' do
      program.stub(:subsidy_map).and_return(double(max_dollar_cap: 0, max_percentage: nil))
      program.eligible_for_subsidy?.should eq false
    end

    it 'should return true if max dollar cap is nil and subsidy map is 1' do
      program.stub(:subsidy_map).and_return(double(max_dollar_cap: nil, max_percentage: 1))
      program.eligible_for_subsidy?.should eq true
    end

    it 'should return true if max dollar cap is 1 and subsidy map is nil' do
      program.stub(:subsidy_map).and_return(double(max_dollar_cap: 1, max_percentage: nil))
      program.eligible_for_subsidy?.should eq true
    end

    it 'should return false if max dollar cap is nil and subsidy map is nil' do
      program.stub(:subsidy_map).and_return(double(max_dollar_cap: nil, max_percentage: nil))
      program.eligible_for_subsidy?.should eq false
    end
  end

  describe "relationship methods" do

    describe "service providers lookup" do

      it "should return an organization's service providers if they exist" do
        program.service_providers_lookup.should eq([service_provider])
      end

      it "should return parent organization's service provider if child organization does not have one" do
        core.service_providers_lookup.should eq([service_provider])
      end
    end

    describe "all service providers" do

      it "should return an organization's own service providers" do
        program.all_service_providers.should include(service_provider)
      end

      it "should return the parent's service providers" do
        core.all_service_providers.should include(service_provider)
      end

      it "should return the child's service providers if process ssrs is set" do
        provider.update_attributes(process_ssrs: 1)
        provider.all_service_providers.should include(service_provider)
      end
    end

    describe "all super users" do

      it "should return an organization's own super users" do
        program.all_super_users.should include(super_user)
      end

      it "should return the parent's super users" do
        core.all_super_users.should include(super_user)
      end

      it "should return the child's super users" do
        provider.update_attributes(process_ssrs: 1)
        provider.all_super_users.should include(super_user)
      end
    end

    describe "get available statuses" do

      it "should set the status to the parent's status if there is one" do
        core.get_available_statuses.should eq({"draft"=>"Draft", "submitted"=>"Submitted"})
      end

      it "should set the status to the default if there are no parent statuses" do
        provider.get_available_statuses.should include("draft" => "Draft", "submitted" => "Submitted", "complete" => "Complete", "in_process" => "In Process", "awaiting_pi_approval" => "Awaiting Requester Response", "on_hold" => "On Hold")
      end

      it "should not get the parent's status if it already has a status" do
        program.get_available_statuses.should eq({"draft"=>"Draft", "submitted"=>"Submitted"})
      end
    end

    context "patient visit calendar" do

      let!(:core1)    { FactoryGirl.create(:core, show_in_cwf: true) }
      let!(:core2)    { FactoryGirl.create(:core, show_in_cwf: true) }
      describe "get cwf organizations" do

        it "should return an array of all organizations flagged to show in clinical work fulfillment" do
          Organization.get_cwf_organizations.should include(core1, core2)
        end
      end
    end
  end
end

