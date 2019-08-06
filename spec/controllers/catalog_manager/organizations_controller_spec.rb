# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

require 'rails_helper'

RSpec.describe CatalogManager::OrganizationsController do

  before :each do
    @user = create(:identity, catalog_overlord: true)
    log_in_catalog_manager_identity(obj: @user)
  end

  describe '#create' do
    it 'should create an organization with user access' do
      expect{
        post :create, params: { organization: attributes_for(:organization) }, xhr: true
      }.to change(Organization, :count).by(1)
      expect(@user.catalog_manager_rights.pluck(:organization_id).include?(Organization.first.id)).to eq(true)
    end
  end

  describe '#update' do
    before :each do
      @org = create(:organization, name: 'disorganized')
    end

    it 'should update an existing organization' do
      expect{
        put :update, params: { id: @org.id, organization: { name: 'organized' } }, xhr: true
        @org.reload
      }.to change(@org, :name).to('organized')
    end
  end

  describe '#remove_user_rights_row' do
    before :each do
      @org  = create(:organization)
              create(:super_user, identity: @user, organization: @org)
              create(:catalog_manager, identity: @user, organization: @org)
              create(:service_provider, identity: @user, organization: @org)
    end

    it 'should destroy existing user rights' do
      post :remove_user_rights_row, params: { user_rights: { identity_id: @user.id, organization_id: @org.id } }, xhr: true

      expect(@user.super_users.count).to eq(0)
      expect(@user.catalog_managers.count).to eq(0)
      expect(@user.service_providers.count).to eq(0)
    end
  end

  describe '#remove_fulfillment_rights_row' do
    before :each do
      @org  = create(:organization)
              create(:clinical_provider, identity: @user, organization: @org)
    end

    it 'should destroy existing clinical providers' do
      expect{
        post :remove_fulfillment_rights_row, params: { fulfillment_rights: { identity_id: @user.id, organization_id: @org.id } }, xhr: true
      }.to change(@user.clinical_providers, :count).by(-1)
    end
  end

  describe '#toggle_default_statuses' do
    before :each do
      @org = create(:organization, use_default_statuses: true)
    end

    it 'should toggle use_default_statuses' do
      expect{
        post :toggle_default_statuses, params: { organization_id: @org.id, checked: false }, xhr: true
        @org.reload
      }.to change(@org, :use_default_statuses).to(false)
    end
  end

  describe '#update_status_row' do
    before :each do
      @org = create(:organization)
    end

    it 'should update available statuses' do
      @status = @org.available_statuses.first

      expect{
        post :update_status_row, params: { organization_id: @org.id, status_type: 'AvailableStatus', status_key: @status.status, selected: true }, xhr: true
        @status.reload
      }.to change(@status, :selected).to(true)
    end

    it 'should update editable statuses' do
      @status = @org.editable_statuses.first

      expect{
        post :update_status_row, params: { organization_id: @org.id, status_type: 'EditableStatus', status_key: @status.status, selected: true }, xhr: true
        @status.reload
      }.to change(@status, :selected).to(true)
    end
  end

  describe '#increase_decrease_rates' do
    before :each do
      @org      = create(:organization)
      @service  = create(:service, organization: @org)
      @pm       = create(:pricing_map, service: @service, effective_date: Date.new(2018, 1, 1), display_date: Date.new(2018, 1, 1))
    end

    it 'should change pricing map rates' do
      expect_any_instance_of(Service).to receive(:increase_decrease_pricing_map)
      post :increase_decrease_rates, params: { organization_id: @org.id, effective_date: Date.new(2018, 1, 2).to_s, display_date: Date.new(2018, 1, 2).to_s }, xhr: true
    end
  end

  describe '#add_associated_survey' do
    before :each do
      @org    = create(:organization)
      @survey = create(:system_survey)
    end

    it 'should add an associated survey' do
      expect{
        post :add_associated_survey, params: { surveyable_id: @org.id, survey_id: @survey.id }, xhr: true
        @org.reload
      }.to change(@org.associated_surveys, :count).by(1)
    end

    context 'survey is already associated' do
      before :each do
        create(:associated_survey, survey_id: @survey.id, associable: @org)
      end

      it 'should not add the survey' do
        expect{
          post :add_associated_survey, params: { surveyable_id: @org.id, survey_id: @survey.id }, xhr: true
          @org.reload
        }.to change(@org.associated_surveys, :count).by(0)
      end
    end
  end

  describe '#remove_associated_survey' do
    before :each do
      @org                = create(:organization)
      @survey             = create(:system_survey)
      @associated_survey  = create(:associated_survey, associable: @org, survey: @survey)
    end

    it 'should remove an existing associated survey' do
      expect{
        post :remove_associated_survey, params: { associated_survey_id: @associated_survey.id }, xhr: true
        @org.reload
      }.to change(@org.associated_surveys, :count).by(-1)
    end
  end
end
