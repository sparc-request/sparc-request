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

# index new create edit update delete show

describe StudiesController do
  let!(:service_request) { FactoryGirl.create_without_validation(:service_request) }
  let!(:identity) { FactoryGirl.create(:identity) }

  stub_controller

  context 'do not have a study' do
    describe 'GET new' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :new, { :id => nil, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set study' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :new, { :id => nil, :format => :js }.with_indifferent_access

        assigns(:protocol).class.should eq Study
        assigns(:protocol).requester_id.should eq identity.id
        assigns(:protocol).research_types_info.should_not eq nil
        assigns(:protocol).human_subjects_info.should_not eq nil
        assigns(:protocol).vertebrate_animals_info.should_not eq nil
        assigns(:protocol).investigational_products_info.should_not eq nil
        assigns(:protocol).ip_patents_info.should_not eq nil
        assigns(:protocol).study_types.should_not eq nil
        assigns(:protocol).impact_areas.should_not eq nil
        assigns(:protocol).affiliations.should_not eq nil
      end
    end

    describe 'GET create' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should create a study with the given parameters' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js, :study => { :title => 'this is the title', :funding_status => 'not in a million years' } }.with_indifferent_access
        assigns(:protocol).title.should eq 'this is the title'
        assigns(:protocol).funding_status.should eq 'not in a million years'
      end

      it 'should setup study types if the study is invalid' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js, :study => { :title => 'this is the title', :funding_status => 'not in a million years' } }.with_indifferent_access
        assigns(:protocol).study_types.should_not eq nil
        assigns(:protocol).impact_areas.should_not eq nil
        assigns(:protocol).affiliations.should_not eq nil
      end

      it 'should put the study id into the session' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js }.with_indifferent_access
        session[:saved_study_id].should eq assigns(:protocol).id
      end
    end
  end

  context 'already have a study' do
    let!(:study) {
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.save!(validate: false)
      project_role = FactoryGirl.create(
          :project_role,
          protocol_id: study.id,
          identity_id: identity.id,
          project_rights: "approve",
          role: "pi")
      study.reload
      study
    }

    describe 'GET edit' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :edit, { :id => study.id, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set study' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :edit, { :id => study.id, :format => :js }.with_indifferent_access
        assigns(:protocol).class.should eq Study
      end

      # TODO: check that populate_for_edit was called
    end

    describe 'GET update' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :update, { :id => study.id, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set study' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :update, { :id => study.id, :format => :js }.with_indifferent_access
        assigns(:protocol).class.should eq Study
        assigns(:protocol).study_types.should_not eq nil
        # TODO: check that setup_study_types was called
        # TODO: check that setup_impact_affiliations was called
        # TODO: check that setup_affiliations was called
      end
    end

    describe 'GET destroy' do
      # TODO: method is not implemented
    end
  end
end