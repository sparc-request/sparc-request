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
require 'rails_helper'

RSpec.describe 'ProtocolAuthorizer', type: :model do
  before :each do
    @identity = Identity.new
    @identity.approved = true
    @identity.save(validate: false)

    @protocol = Protocol.new
    @protocol.save(validate: false)
  end

  it 'should not authorize view and edit if both protocol and identity are nil' do
    pa = ProtocolAuthorizer.new(nil, nil)
    expect(pa.can_view?).to eq (false)
    expect(pa.can_edit?).to eq (false)
  end

  it 'should not authorize view and edit if protocol is nil' do
    pa = ProtocolAuthorizer.new(nil, @identity)
    expect(pa.can_view?).to eq (false)
    expect(pa.can_edit?).to eq (false)
  end

  it 'should not authorize view and edit if identity and project roles are nil' do
    pa = ProtocolAuthorizer.new(@protocol, nil)
    expect(pa.can_view?).to eq (false)
    expect(pa.can_edit?).to eq (false)
  end

  describe 'checks project roles and' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
    end

    it 'should not authorize view and edit if identity is nil and projects roles size is one' do
      @project_role.save(validate: false)

      pa = ProtocolAuthorizer.new(@protocol, nil)
      expect(pa.can_view?).to eq (false)
      expect(pa.can_edit?).to eq (false)
    end

    it 'should authorize view and edit if identity has "approve" rights' do
      @project_role.project_rights = 'approve'
      @project_role.save(validate: false)

      pa = ProtocolAuthorizer.new(@protocol, @identity)
      expect(pa.can_view?).to eq (true)
      expect(pa.can_edit?).to eq (true)
    end

    it 'should authorize view and edit if identity has "request" rights' do
      @project_role.project_rights = 'request'
      @project_role.save(validate: false)

      pa = ProtocolAuthorizer.new(@protocol, @identity)
      expect(pa.can_view?).to eq (true)
      expect(pa.can_edit?).to eq (true)
    end

    it 'should authorize view only if identity has "view" rights' do
      @project_role.project_rights = 'view'
      @project_role.save(validate: false)

      pa = ProtocolAuthorizer.new(@protocol, @identity)
      expect(pa.can_view?).to eq (true)
      expect(pa.can_edit?).to eq (false)
    end

    it 'should not authorize view and edit if identity has "none" rights' do
      @project_role.project_rights = 'none'
      @project_role.save(validate: false)

      pa = ProtocolAuthorizer.new(@protocol, @identity)
      expect(pa.can_view?).to eq (false)
      expect(pa.can_edit?).to eq (false)
    end

    it 'should not authorize view and edit if identity has empty "" rights' do
      @project_role.project_rights = ''
      @project_role.save(validate: false)

      pa = ProtocolAuthorizer.new(@protocol, @identity)
      expect(pa.can_view?).to eq (false)
      expect(pa.can_edit?).to eq (false)
    end

    it 'should NOT authorize view and edit if another identity has "approve" rights' do
      @associated_user = Identity.new
      @associated_user.approved = true
      @associated_user.save(validate: false)

      @associated_user_project_role = ProjectRole.new
      @associated_user_project_role.identity_id = @associated_user.id
      @associated_user_project_role.protocol_id = @protocol.id
      @associated_user_project_role.project_rights = 'approve'
      @associated_user_project_role.save(validate: false)

      pa = ProtocolAuthorizer.new(@protocol, @identity)
      expect(pa.can_view?).to eq (false)
      expect(pa.can_edit?).to eq (false)
    end

    it 'should NOT authorize view and edit if another identity has "view" rights' do
      @associated_user = Identity.new
      @associated_user.approved = true
      @associated_user.save(validate: false)

      @associated_user_project_role = ProjectRole.new
      @associated_user_project_role.identity_id = @associated_user.id
      @associated_user_project_role.protocol_id = @protocol.id
      @associated_user_project_role.project_rights = 'view'
      @associated_user_project_role.save(validate: false)

      pa = ProtocolAuthorizer.new(@protocol, @identity)
      expect(pa.can_view?).to eq (false)
      expect(pa.can_edit?).to eq (false)
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

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end

        it 'should NOT authorize view and edit if identity is a clinical provider for a sub service request that is servicing the protocol' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @core.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @core.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end
      end

      describe 'unrelated cores' do
        before :each do
          @unrelated_core = Core.new
          @unrelated_core.type = "Core"
          @unrelated_core.name = "REDCap 2"
          @unrelated_core.parent_id = @program.id
          @unrelated_core.save(validate: false)
        end

        it 'should NOT authorize view and edit if identity is a service provider for an unrelated core' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @unrelated_core.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit if identity is a clinical provider for an unrelated core' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @unrelated_core.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit if identity is a super user for an unrelated core' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @unrelated_core.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

      end

      describe 'programs' do
        it 'should authorize view and edit if identity is a service provider for a sub service request that is servicing the protocol' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @program.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end

        it 'should NOT authorize view and edit if identity is a clinical provider for a sub service request that is servicing the protocol' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @program.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @program.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end
      end

      describe 'unrelated programs' do
        before :each do
          @unrelated_program = Program.new
          @unrelated_program.type = "Program"
          @unrelated_program.name = "BMI 2"
          @unrelated_program.parent_id = @provider.id
          @unrelated_program.save(validate: false)
        end

        it 'should NOT authorize view and edit if identity is a service provider for an unrelated program' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @unrelated_program.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit if identity is a clinical provider for an unrelated program' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @unrelated_program.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit if identity is a super user for  an unrelated program' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @unrelated_program.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end
      end

      describe 'providers' do
        it 'should authorize view and edit if identity is a service provider for a sub service request that is servicing the protocol' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @provider.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end

        it 'should NOT authorize view and edit even if identity is a clinical provider for a provider' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @provider.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @provider.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end
      end

      describe 'unrelated providers' do
        before :each do
          @unrelated_provider = Provider.new
          @unrelated_provider.type = "Provider"
          @unrelated_provider.abbreviation = "ICTS 2"
          @unrelated_provider.parent_id = @institution.id
          @unrelated_provider.save(validate: false)
        end

        it 'should NOT authorize view and edit if identity is a service provider for an unrelated provider' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @unrelated_provider.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit if identity is a super user for an unrelated provider' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @unrelated_provider.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end
      end

      describe 'institutions' do
        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @institution.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end
      end

      describe 'unrelated institutions' do
        before :each do
          @unrelated_institution = Institution.new
          @unrelated_institution.type = "Institution"
          @unrelated_institution.abbreviation = "TECHU 2"
          @unrelated_institution.save(validate: false)
        end

        it 'should NOT authorize view and edit if identity is a super user for an unrelated institution' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @unrelated_institution.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end
      end
    end

    describe 'sub service request connected to a program and users within' do
      before :each do
        @sub_service_request = SubServiceRequest.new
        @sub_service_request.organization_id = @program.id
        @sub_service_request.service_request_id = @service_request.id
        @sub_service_request.save(validate: false)
      end

      describe 'cores' do
        it 'should NOT authorize view and edit' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @core.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @core.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @core.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end
      end

      describe 'programs' do
        it 'should authorize view and edit if identity is a service provider for a sub service request that is servicing the protocol' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @program.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end

        it 'should NOT authorize view and edit if identity is a clinical provider for a sub service request that is servicing the protocol' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @program.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @program.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end
      end

      describe 'unrelated programs' do
        before :each do
          @unrelated_program = Program.new
          @unrelated_program.type = "Program"
          @unrelated_program.name = "BMI 2"
          @unrelated_program.parent_id = @provider.id
          @unrelated_program.save(validate: false)
        end

        it 'should NOT authorize view and edit if identity is a service provider for an unrelated program' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @unrelated_program.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit if identity is a clinical provider for an unrelated program' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @unrelated_program.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit if identity is a super user for  an unrelated program' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @unrelated_program.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end
      end

      describe 'providers' do
        it 'should authorize view and edit if identity is a service provider for a sub service request that is servicing the protocol' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @provider.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end

        it 'should NOT authorize view and edit even if identity is a clinical provider for a provider' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @provider.id
          @clinical_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @provider.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end
      end

      describe 'unrelated providers' do
        before :each do
          @unrelated_provider = Provider.new
          @unrelated_provider.type = "Provider"
          @unrelated_provider.abbreviation = "ICTS 2"
          @unrelated_provider.parent_id = @institution.id
          @unrelated_provider.save(validate: false)
        end

        it 'should NOT authorize view and edit if identity is a service provider for an unrelated provider' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @unrelated_provider.id
          @service_provider.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end

        it 'should NOT authorize view and edit if identity is a super user for an unrelated provider' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @unrelated_provider.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end
      end

      describe 'institutions' do
        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @institution.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (true)
          expect(pa.can_edit?).to eq (true)
        end
      end

      describe 'unrelated institutions' do
        before :each do
          @unrelated_institution = Institution.new
          @unrelated_institution.type = "Institution"
          @unrelated_institution.abbreviation = "TECHU 2"
          @unrelated_institution.save(validate: false)
        end

        it 'should NOT authorize view and edit if identity is a super user for an unrelated institution' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @unrelated_institution.id
          @super_user.save(validate: false)

          pa = ProtocolAuthorizer.new(@protocol, @identity)
          expect(pa.can_view?).to eq (false)
          expect(pa.can_edit?).to eq (false)
        end
      end
    end

  end

end
