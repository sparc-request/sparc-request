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

require 'rails_helper'

RSpec.describe CatalogManager::ProgramsController do
  let!(:logged_in_user) {create(:identity)}

  before :each do
    allow(controller).to receive(:authenticate_identity!).
      and_return(true)
    allow(controller).to receive(:current_identity).
      and_return(logged_in_user)
  end


  describe '#create' do
    before :each do
      @provider = create(:provider)
      post :create, name: 'Some Program', provider_id: @provider.id, format: :js
    end

    it 'should create a provider' do
      expect(Program.count).to eq(1)
    end

    it 'should assign @organization' do
      expect(assigns(:organization)).to be_an_instance_of(Program)
    end

    it 'should associate the parent organization to @organization' do
      expect(assigns(:organization).parent_id).to eq(@provider.id)
    end

    it 'should create a subsidy map for @organization' do
      expect(assigns(:organization).subsidy_map).to_not be_nil
    end

    it { is_expected.to render_template "programs/create" }
    it { is_expected.to respond_with :ok }
  end

  describe '#show' do
    before :each do
      @organization = create(:program)
      logged_in_user.catalog_manager_rights.create(organization_id: @organization.id)

      xhr :get, :show, id: @organization.id
    end

    it 'should assign @path' do
      expect(assigns(:path)).to eq(catalog_manager_program_path)
    end

    it 'should assign @organization' do
      expect(assigns(:organization)).to eq(@organization)
    end

    it { is_expected.to render_template "organizations/show" }
    it { is_expected.to respond_with :ok }
  end

  describe '#update' do
    before :each do
      @organization = create(:program, name: 'Some Program')
      logged_in_user.catalog_manager_rights.create( organization_id: @organization.id )
      pricing_setup = {id: '',
                       display_date:   '2016-06-27',
                       effective_date: '2016-06-28',
                       federal:   '100',
                       corporate: '100',
                       other:     '100',
                       member:    '100',
                       college_rate_type:      'federal',
                       federal_rate_type:      'federal',
                       foundation_rate_type:   'federal',
                       industry_rate_type:     'federal',
                       investigator_rate_type: 'federal',
                       internal_rate_type:     'federal',
                       unfunded_rate_type:     'federal',
                       newly_created: 'true'}
      @params = ActionController::Parameters.new(
                { id: @organization.id,
                  program: { name: 'New Program Name',
                              tag_list: nil },
                  pricing_setups: {blank_pricing_setup: pricing_setup} })

      xhr :put, :update, @params, format: :js
    end

    it 'should assign @attributes' do
      @params[:program][:tag_list] = ''
      expect(assigns(:attributes)).to eq(@params[:program])
    end

    it 'should assign @organization' do
      expect(assigns(:organization)).to eq(@organization)
    end

    it 'should update the organization' do
      @organization.reload
      expect(@organization.name).to eq(@params[:program][:name])
    end

    it 'should save pricing setups' do
      expect(@organization.pricing_setups.count).to eq(1)
    end

    it 'should set organization tags' do
      expect(assigns(:attributes)[:tag_list]).to eq('')
    end

    it { is_expected.to render_template "organizations/update" }
    it { is_expected.to respond_with :ok }
  end
end