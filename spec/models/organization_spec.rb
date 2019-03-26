# Copyright © 2011-2019 MUSC Foundation for Research Development
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
require 'rails_helper'

RSpec.describe Organization, type: :model do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  describe 'submission emails lookup' do

      let!(:submission_email_1) {create(:submission_email, organization_id: provider.id)}
      let!(:submission_email_2) {create(:submission_email, organization_id: program.id)}
      let!(:submission_email_3) {create(:submission_email, organization_id: core.id)}

      before :each do
        provider.update_attributes(process_ssrs: 1)
        core.update_attributes(process_ssrs: 1)
        sub_service_request.update_attributes(organization_id: core.id)
      end

      it "should return the first submission e-mails it finds" do
        expect(sub_service_request.organization.submission_emails_lookup).to include(submission_email_3)
        core.submission_emails.delete_all
        sub_service_request.reload
        expect(sub_service_request.organization.submission_emails_lookup).to include(submission_email_2)
        program.submission_emails.delete_all
        sub_service_request.reload
        expect(sub_service_request.organization.submission_emails_lookup).to include(submission_email_1)

        # now let's add the core back
        submission_email_4 = core.submission_emails.create(email: submission_email_3.email)
        sub_service_request.reload
        expect(sub_service_request.organization.submission_emails_lookup).to include(submission_email_4)
      end
  end

  describe 'parent' do

    it "should return nil if there is no parent" do
     expect(institution.parent).to equal nil
    end

    it "should return the parent if there is a parent" do
      expect(provider.parent).to eq institution
    end
  end

  describe 'parents' do

    it 'should return an empty array if there is no parent' do
      expect(institution.parents).to eq []
    end

    it 'should return a single parent if it has a parent and the parent has no parent' do
      expect(provider.parents).to eq [ institution ]
    end

    it 'should return the parent and grandparent if there is a grandparent' do
      expect(program.parents).to eq [ provider, institution ]
    end
  end

  describe 'hierarchy methods' do

    let!(:program2) { create(:program, parent_id: provider.id) }
    let!(:core2) { create(:core, parent_id: program2.id) }

    describe 'process ssrs parent' do

      it 'should return the core if process ssrs is set to true' do
        core.process_ssrs = true
        core.save
        expect(core.process_ssrs_parent).to eq(core)
      end

      it 'should return the program if process ssrs is on the program' do
        program.process_ssrs = true
        program.save
        expect(core.process_ssrs_parent).to eq(program)
      end

      it 'should return the program if process ssrs is on the provider and the program' do
        program.process_ssrs = true
        program.save
        provider.process_ssrs = true
        provider.save
        expect(core.process_ssrs_parent).to eq(program)
      end

      it 'should return the correct program if process ssrs is set on multiple programs' do
        program.process_ssrs = true
        program.save
        program2.process_ssrs = true
        program2.save
        expect(core.process_ssrs_parent).to eq(program)
        expect(core2.process_ssrs_parent).to eq(program2)
      end
    end

    describe 'service providers for services' do

      let!(:provider_organization)       { create(:provider) }
      let!(:program_organization)        { create(:program, parent_id: provider_organization.id) }
      let!(:core_organization)           { create(:core, parent_id: program_organization.id) }
      let!(:program_service)             { create(:service, organization_id: program_organization.id) }
      let!(:core_service)                { create(:service, organization_id: core_organization.id) }

      it "should return true if a service has a service provider in the tree" do
        service_provider = create(:service_provider, organization_id: provider_organization.id)
        expect(program_organization.service_providers_for_child_services?).to eq(true)
      end

      it "should return false if a service does not have a service provider in the tree" do
        expect(program_organization.service_providers_for_child_services?).to eq(false)
      end

      it "should return false if there is a service provider, but it's only on the current organization" do
        service_provider = create(:service_provider, organization_id: program_organization.id)
        expect(program_organization.service_providers_for_child_services?).to eq(false)
      end
    end

    describe 'all child services' do

      let!(:service2) { create(:service, organization_id: core2.id) }
      let!(:program3) { create(:program, parent_id: provider.id) }
      let!(:service3) { create(:service, organization_id: program3.id) }
      let!(:program4) { create(:program) }
      let!(:core3)    { create(:core, parent_id: program4.id) }

      before :each do
        service.update_attributes(organization_id: core.id)
      end

      it 'should return the correct service for a core' do
        expect(core.all_child_services).to eq([service])
      end

      it 'should return the services under a program with cores' do
        expect(program.all_child_services).to eq([service])
      end

      it 'should return the services under a program without cores' do
        expect(program3.all_child_services).to eq([service3])
      end

      it 'should return the services under a program that offers both services and cores' do
        prog = create(:program)
        prog_core = create(:core, parent_id: prog.id)
        serv1 = create(:service, organization_id: prog.id)
        serv2 = create(:service, organization_id: prog_core.id)
        expect(prog.all_child_services).to include(serv1, serv2)
      end

      it 'should return the services under a provider' do
        expect(provider.all_child_services).to include(service, service2, service3)
      end

      it 'should return the services under an institution' do
        expect(institution.all_child_services).to include(service, service2, service3)
      end
    end
  end

  describe 'update descendants availability' do

    it 'should update all descendants availability to false when input is false' do
      provider  = create(:provider, is_available: true)
      program   = create(:program, parent: provider, is_available: true)
      core      = create(:core, parent: program, is_available: true)
      service   = create(:service, organization: core, is_available: true)

      provider.update_descendants_availability("0")

      expect(program.reload.is_available).to eq(false)
      expect(core.reload.is_available).to eq(false)
      expect(service.reload.is_available).to eq(false)
    end
  end

  describe 'current_pricing_setup' do

    it 'should raise an exception if there are no pricing setups' do
      organization = build(:provider)
      organization.save!
      expect(lambda { organization.current_pricing_setup }).to raise_exception(ArgumentError)
    end

    it 'should return the only pricing setup if there is one pricing setup and it is in the past' do
      organization = build(:provider, pricing_setup_count: 1)
      organization.pricing_setups[0].display_date = Date.today - 1
      expect(organization.current_pricing_setup).to eq organization.pricing_setups[0]
    end

    it 'should return the most recent pricing setup in the past if there is more than one' do
      organization = build(:provider, pricing_setup_count: 2)
      organization.pricing_setups[0].display_date = Date.today - 1
      organization.pricing_setups[1].display_date = Date.today - 2
      expect(organization.current_pricing_setup).to eq organization.pricing_setups[0]
    end

    it 'should return the most recent pricing setup in the past if there is more than one and the order is reversed' do
      organization = build(:provider, pricing_setup_count: 2)
      organization.pricing_setups[0].display_date = Date.today - 2
      organization.pricing_setups[1].display_date = Date.today - 1
      expect(organization.current_pricing_setup).to eq organization.pricing_setups[1]
    end

    it 'should return the pricing setup in the past if one is in the past and one is in the future' do
      organization = build(:provider, pricing_setup_count: 2)
      organization.pricing_setups[0].display_date = Date.today - 1
      organization.pricing_setups[1].display_date = Date.today + 1
      expect(organization.current_pricing_setup).to eq organization.pricing_setups[0]
    end

    it 'should return the pricing setup in the past if one is in the past and one is in the future and the order is reversed' do
      organization = build(:provider, pricing_setup_count: 2)
      organization.pricing_setups[0].display_date = Date.today + 1
      organization.pricing_setups[1].display_date = Date.today - 1
      expect(organization.current_pricing_setup).to eq organization.pricing_setups[1]
    end

    it 'should return the pricing setup for today if there is a pricing setup with a display date of today' do
      organization = build(:provider, pricing_setup_count: 3)
      organization.pricing_setups[0].display_date = Date.today + 1
      organization.pricing_setups[1].display_date = Date.today
      organization.pricing_setups[2].display_date = Date.today - 1
      expect(organization.current_pricing_setup).to eq organization.pricing_setups[1]
    end
  end

  describe 'pricing setup for date' do

    it 'should raise an exception if there are no pricing setups' do
      organization = create(:provider)
      expect(lambda { organization.pricing_setup_for_date(Date.parse('2012-01-01')) }).to raise_exception(ArgumentError)
    end

    it 'should return the displayed pricing setup for the given date if there is a pricing setup with a display date of that date' do
      organization = build(:provider, pricing_setup_count: 5)
      base_date = Date.parse('2012-01-01')
      organization.pricing_setups[0].display_date = base_date + 1
      organization.pricing_setups[1].display_date = base_date
      organization.pricing_setups[2].display_date = base_date - 1
      organization.pricing_setups[3].display_date = base_date - 2
      organization.pricing_setups[4].display_date = base_date - 3
      expect(organization.pricing_setup_for_date(base_date)).to eq organization.pricing_setups[1]
    end

    # most of these tests would be duplicates of those for
    # current_pricing_setup
  end

  describe 'effective pricing setup for date' do

    it 'should return the pricing setup that is effective on a given date' do
      organization = build(:provider, pricing_setup_count: 5)
      organization = build(:provider, pricing_setup_count: 5)
      base_date = Date.parse('2012-01-01')
      organization.pricing_setups[0].display_date = base_date + 1
      organization.pricing_setups[1].display_date = base_date
      organization.pricing_setups[2].display_date = base_date - 1
      organization.pricing_setups[3].display_date = base_date - 2
      organization.pricing_setups[4].display_date = base_date - 3
      expect(organization.pricing_setup_for_date(base_date)).to eq organization.pricing_setups[1]
    end
  end

  describe 'eligible for subsidy?' do

    it 'should return false if there is no subsidy map' do
      allow(program).to receive(:subsidy_map).and_return(nil)

      expect(program.eligible_for_subsidy?).to eq false
    end

    it 'should return true if max dollar cap is greater than 0' do
      allow(program).to receive(:subsidy_map).and_return(double(max_dollar_cap: 1, max_percentage: 0))

      expect(program.eligible_for_subsidy?).to eq true
    end

    it 'should return true if max percentage is greater than 0' do
      allow(program).to receive(:subsidy_map).and_return(double(max_dollar_cap: 0, max_percentage: 1))

      expect(program.eligible_for_subsidy?).to eq true
    end

    it 'should return false if max dollar cap is 0 and max percentage is 0' do
      allow(program).to receive(:subsidy_map).and_return(double(max_dollar_cap: 0, max_percentage: 0))

      expect(program.eligible_for_subsidy?).to eq false
    end

    it 'should return false if max dollar cap is nil and subsidy map is 0' do
      allow(program).to receive(:subsidy_map).and_return(double(max_dollar_cap: nil, max_percentage: 0))

      expect(program.eligible_for_subsidy?).to eq false
    end

    it 'should return false if max dollar cap is 0 and subsidy map is nil' do
      allow(program).to receive(:subsidy_map).and_return(double(max_dollar_cap: 0, max_percentage: nil))

      expect(program.eligible_for_subsidy?).to eq false
    end

    it 'should return true if max dollar cap is nil and subsidy map is 1' do
      allow(program).to receive(:subsidy_map).and_return(double(max_dollar_cap: nil, max_percentage: 1))

      expect(program.eligible_for_subsidy?).to eq true
    end

    it 'should return true if max dollar cap is 1 and subsidy map is nil' do
      allow(program).to receive(:subsidy_map).and_return(double(max_dollar_cap: 1, max_percentage: nil))

      expect(program.eligible_for_subsidy?).to eq true
    end

    it 'should return false if max dollar cap is nil and subsidy map is nil' do
      allow(program).to receive(:subsidy_map).and_return(double(max_dollar_cap: nil, max_percentage: nil))

      expect(program.eligible_for_subsidy?).to eq false
    end
  end

  describe "relationship methods" do

    describe "service providers lookup" do

      it "should return an organization's service providers if they exist" do
        expect(program.service_providers_lookup).to eq([service_provider])
      end

      it "should return parent organization's service provider if child organization does not have one" do
        expect(core.service_providers_lookup).to eq([service_provider])
      end
    end

    describe "all service providers" do

      it "should return an organization's own service providers" do
        expect(program.all_service_providers).to include(service_provider)
      end

      it "should return the parent's service providers" do
        expect(core.all_service_providers).to include(service_provider)
      end

      it "should return the child's service providers if process ssrs is set" do
        provider.update_attributes(process_ssrs: 1)
        expect(provider.all_service_providers).to include(service_provider)
      end
    end

    describe "all super users" do

      it "should return an organization's own super users" do
        expect(program.all_super_users).to include(super_user)
      end

      it "should return the parent's super users" do
        expect(core.all_super_users).to include(super_user)
      end

      it "should return the child's super users" do
        provider.update_attributes(process_ssrs: 1)
        expect(provider.all_super_users).to include(super_user)
      end
    end

    describe "get available statuses" do

      context "process_ssrs is false" do
        it "should return parent statuses" do
          core.parent.update_attributes(process_ssrs: true, use_default_statuses: false)
          core.parent.available_statuses.where(status: 'administrative_review').first.update_attributes(selected: true)

          expect(core.get_available_statuses).to include({"administrative_review"=>"Administrative Review"})
        end
      end

      context "process_ssrs is true" do
        it "should return default statuses if use_default_statuses is true" do
          core.update_attributes(process_ssrs: true)

          expect(core.get_available_statuses).to include(AvailableStatus.statuses.slice(*AvailableStatus.defaults))
        end

        it "should return custom statuses if use_default_statuses is false" do
          core.update_attributes(process_ssrs: true)
          core.available_statuses.where(status: 'administrative_review').first.update_attributes(selected: true)

          expect(core.get_available_statuses).to include({"administrative_review"=>"Administrative Review"})
        end
      end
    end

    describe 'has_editable_status?' do

      it 'should return true if the current organization or its process_ssrs_parent have editable status in question' do
        org1 = create(:organization, process_ssrs: true)
        org2 = create(:organization, parent_id: org1.id)
        expect(org2.has_editable_status?('draft')).to eq(true)
        expect(org1.has_editable_status?('draft')).to eq(true)
      end

      it 'should return false otherwise' do
        org1 = create(:organization, use_default_statuses: false, process_ssrs: true)
        org1.editable_statuses.destroy_all
        expect(org1.has_editable_status?('draft')).to eq(false)
      end
    end
  end
end
