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

require 'rails_helper'

RSpec.describe Portal::SubServiceRequestsController do
  stub_portal_controller

  before :each do
    @identity = Identity.new
    @identity.approved = true
    @identity.save(validate: false)

    session[:identity_id] = @identity.id

    @protocol = Study.new
    @protocol.type = 'Study'
    @protocol.save(validate: false)

    # create service request and associate it to a protocol via an organization (i.e., core)
    @institution = Institution.new
    @institution.type = "Institution"
    @institution.abbreviation = "TECHU"
    @institution.save(validate: false)

    @provider = Provider.new
    @provider.type = "Provider"
    @provider.abbreviation = "ICTS"
    @provider.parent_id = @institution.id
    @provider.save(validate: false)

    @program = Program.new
    @program.type = "Program"
    @program.name = "BMI"
    @program.parent_id = @provider.id
    @program.save(validate: false)

    @core = Core.new
    @core.type = "Core"
    @core.name = "REDCap"
    @core.parent_id = @program.id
    @core.save(validate: false)

    @service_request = ServiceRequest.new
    @service_request.protocol_id = @protocol.id
    @service_request.save(validate: false)

    @sub_service_request = SubServiceRequest.new
    @sub_service_request.organization_id = @core.id
    @sub_service_request.service_request_id = @service_request.id
    @sub_service_request.save(validate: false)

    @pi_identity = Identity.new
    @pi_identity.approved = true
    @pi_identity.save(validate: false)

    @pi_project_role = ProjectRole.new
    @pi_project_role.identity_id = @pi_identity.id
    @pi_project_role.protocol_id = @protocol.id
    @pi_project_role.project_rights = 'approve'
    @pi_project_role.role = 'primary-pi'
    @pi_project_role.save(validate: false)
  end

  describe 'identity has NO related roles and, thus, no access to' do
    it 'show update_from_project_study_information' do
      get(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id })
      expect(assigns(:protocol)).to eq nil
      expect(response).to render_template(:partial => "_authorization_error")
    end

    it 'update update_from_project_study_information' do
      post(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id,
              :study => { :sponsor_name => 'New Sponsor', :short_title => 'Short Study', :title => 'Long Title', :funding_status => 'funded', :funding_source => 'grant', :has_cofc => false } })
      expect(assigns(:protocol)).to eq nil
      expect(response).to render_template(:partial => "_authorization_error")
    end
  end

  describe 'checks project roles and, if identity has "approve" rights, authorize' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
      @project_role.project_rights = 'approve'
      @project_role.save(validate: false)
    end

    it 'show' do
      get(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id })
      expect(assigns(:protocol)).to eq @protocol
      expect(assigns(:sub_service_request)).to eq @sub_service_request
      expect(response).to render_template("show")
    end

    it 'update' do
      post(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id,
              :study => { :sponsor_name => 'New Sponsor', :short_title => 'Short Study', :title => 'Long Title', :funding_status => 'funded', :funding_source => 'grant', :has_cofc => false } })
      expect(assigns(:protocol)).to eq @protocol
      expect(assigns(:sub_service_request)).to eq @sub_service_request
      expect(response).to redirect_to "/portal/admin/sub_service_requests/#{@sub_service_request.id}"
    end
  end

  describe 'checks project roles and, if identity has "request" rights, authorize' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
      @project_role.project_rights = 'request'
      @project_role.save(validate: false)
    end

    it 'show' do
      get(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id })
      expect(assigns(:protocol)).to eq @protocol
      expect(assigns(:sub_service_request)).to eq @sub_service_request
      expect(response).to render_template("show")
    end

    it 'update' do
      post(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id,
              :study => { :sponsor_name => 'New Sponsor', :short_title => 'Short Study', :title => 'Long Title', :funding_status => 'funded', :funding_source => 'grant', :has_cofc => false } })
      expect(assigns(:protocol)).to eq @protocol
      expect(assigns(:sub_service_request)).to eq @sub_service_request
      expect(response).to redirect_to "/portal/admin/sub_service_requests/#{@sub_service_request.id}"
    end
  end

  describe 'checks project roles and, if identity has "view" rights,' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
      @project_role.project_rights = 'view'
      @project_role.save(validate: false)
    end

    it 'show' do
      get(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id })
      expect(assigns(:protocol)).to eq @protocol
      expect(assigns(:sub_service_request)).to eq @sub_service_request
      expect(response).to render_template("show")
    end

    it 'do NOT update' do
      post(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id,
              :study => { :sponsor_name => 'New Sponsor', :short_title => 'Short Study', :title => 'Long Title', :funding_status => 'funded', :funding_source => 'grant', :has_cofc => false } })
      expect(assigns(:protocol)).to eq nil
      expect(response).to render_template(:partial => "_authorization_error")
    end
  end

  describe 'checks project roles and, if identity has "none" rights, do NOT authorize' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
      @project_role.project_rights = 'none'
      @project_role.save(validate: false)
    end

    it 'show update_from_project_study_information' do
      get(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id })
      expect(assigns(:protocol)).to eq nil
      expect(response).to render_template(:partial => "_authorization_error")
    end

    it 'update update_from_project_study_information' do
      post(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id,
              :study => { :sponsor_name => 'New Sponsor', :short_title => 'Short Study', :title => 'Long Title', :funding_status => 'funded', :funding_source => 'grant', :has_cofc => false } })
      expect(assigns(:protocol)).to eq nil
      expect(response).to render_template(:partial => "_authorization_error")
    end
  end

  describe 'checks service providers, clinical providers, and super users for a ' do
    before :each do
      # create service request and associate it to a protocol via an organization (i.e., core)
      @institution = Institution.new
      @institution.type = "Institution"
      @institution.abbreviation = "TECHU"
      @institution.save(validate: false)

      @provider = Provider.new
      @provider.type = "Provider"
      @provider.abbreviation = "ICTS"
      @provider.parent_id = @institution.id
      @provider.save(validate: false)

      @program = Program.new
      @program.type = "Program"
      @program.name = "BMI"
      @program.parent_id = @provider.id
      @program.save(validate: false)

      @core = Core.new
      @core.type = "Core"
      @core.name = "REDCap"
      @core.parent_id = @program.id
      @core.save(validate: false)

      @service_request = ServiceRequest.new
      @service_request.protocol_id = @protocol.id
      @service_request.save(validate: false)
    end

    describe 'sub service request connected to a core and users within' do
      before :each do
        @sub_service_request = SubServiceRequest.new
        @sub_service_request.organization_id = @core.id
        @sub_service_request.service_request_id = @service_request.id
        @sub_service_request.save(validate: false)
      end

      describe 'cores' do
        it 'should authorize view and edit if identity is a service provider for a sub service request that is servicing the protocol' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @core.id
          @service_provider.save(validate: false)

          get(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id })
          expect(assigns(:protocol)).to eq @protocol
          expect(assigns(:sub_service_request)).to eq @sub_service_request
          expect(response).to render_template("show")

          post(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id,
                  :study => { :sponsor_name => 'New Sponsor', :short_title => 'Short Study', :title => 'Long Title', :funding_status => 'funded', :funding_source => 'grant', :has_cofc => false } })
          expect(assigns(:protocol)).to eq @protocol
          expect(assigns(:sub_service_request)).to eq @sub_service_request
          expect(response).to redirect_to "/portal/admin/sub_service_requests/#{@sub_service_request.id}"
        end

        it 'should NOT authorize view and edit if identity is a clinical provider for a sub service request that is servicing the protocol' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @core.id
          @clinical_provider.save(validate: false)

          get(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id })
          expect(assigns(:protocol)).to eq nil
          expect(response).to render_template(:partial => "_authorization_error")

          post(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id,
                  :study => { :sponsor_name => 'New Sponsor', :short_title => 'Short Study', :title => 'Long Title', :funding_status => 'funded', :funding_source => 'grant', :has_cofc => false } })
          expect(assigns(:protocol)).to eq nil
          expect(response).to render_template(:partial => "_authorization_error")
        end

        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @core.id
          @super_user.save(validate: false)

          get(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id })
          expect(assigns(:protocol)).to eq @protocol
          expect(assigns(:sub_service_request)).to eq @sub_service_request
          expect(response).to render_template("show")

          post(:update_from_project_study_information, {:format => :html, :protocol_id => @protocol.id, :id => @sub_service_request.id,
                  :study => { :sponsor_name => 'New Sponsor', :short_title => 'Short Study', :title => 'Long Title', :funding_status => 'funded', :funding_source => 'grant', :has_cofc => false } })
          expect(assigns(:protocol)).to eq @protocol
          expect(assigns(:sub_service_request)).to eq @sub_service_request
          expect(response).to redirect_to "/portal/admin/sub_service_requests/#{@sub_service_request.id}"
        end
      end
    end
  end
end
