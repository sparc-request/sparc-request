require 'rails_helper'

RSpec.describe Dashboard::IdentityOrganizations do

  describe '#admin_organizations_with_protocols' do
    context "Identity is super user at provider level" do
      context "Identity is service_provider at institution level" do
        it "should return organizations for super_users and service_providers that have protocols" do
          institution_organization = create(:institution_without_validations)
          provider_organization    = create(:provider_without_validations, parent_id:  institution_organization.id)
          program_organization     = create(:program_without_validations, parent_id: provider_organization.id)

          provider_protocol        = create(:protocol_without_validations)
          provider_sr              = create(:service_request_without_validations, protocol_id:  provider_protocol.id)
          create(:sub_service_request_without_validations, service_request_id:  provider_sr.id, organization_id: provider_organization.id)

          program_protocol         = create(:protocol_without_validations)
          program_sr               = create(:service_request_without_validations, protocol_id:  program_protocol.id)
          create(:sub_service_request_without_validations, service_request_id:  program_sr.id, organization_id: program_organization.id)

          identity                 = create(:identity)
          create(:service_provider, identity: identity, organization: institution_organization)
          create(:super_user, identity: identity, organization: provider_organization)

          orgs_with_protocols = []
          orgs_with_protocols << provider_organization.id # There is a protocol attached at the provider level
          orgs_with_protocols << program_organization.id # There is a protocol attached at the program level

          # Should return an array with the provider and program org, not the institution org since it does not have a protocol attached
          expect(Dashboard::IdentityOrganizations.new(identity.id).admin_organizations_with_protocols.map(&:id)).to eq(orgs_with_protocols.flatten.sort)
        end
      end
    end
    context "Identity is not a super user or service provider" do

      it "should not return any organizations" do
        identity                 = create(:identity)
        institution_organization = create(:institution_without_validations)
        provider_organization    = create(:provider_without_validations, parent_id:  institution_organization.id)
        program_organization     = create(:program_without_validations, parent_id: provider_organization.id)

        provider_protocol        = create(:protocol_without_validations, primary_pi: identity)
        provider_sr              = create(:service_request_without_validations, protocol_id:  provider_protocol.id)
        create(:sub_service_request_without_validations, service_request_id:  provider_sr.id, organization_id: provider_organization.id)

        program_protocol         = create(:protocol_without_validations, primary_pi: identity)
        program_sr               = create(:service_request_without_validations, protocol_id:  program_protocol.id)
        create(:sub_service_request_without_validations, service_request_id:  program_sr.id, organization_id: program_organization.id)


        # This Identity does not have super user or service provider status so we should expect an empty array
        expect(Dashboard::IdentityOrganizations.new(identity.id).admin_organizations_with_protocols.map(&:id)).to eq([])
      end
    end
  end

  describe '#general_user_organizations_with_protocols' do
    context "Identity is not a super user or service provider" do
      context "Identity is service_provider at institution level" do
        it "should not return any organizations" do
          institution_organization = create(:institution_without_validations)
          provider_organization    = create(:provider_without_validations, parent_id:  institution_organization.id)
          program_organization     = create(:program_without_validations, parent_id: provider_organization.id)

          provider_protocol        = create(:protocol_without_validations)
          provider_sr              = create(:service_request_without_validations, protocol_id:  provider_protocol.id)
          create(:sub_service_request_without_validations, service_request_id:  provider_sr.id, organization_id: provider_organization.id)

          program_protocol         = create(:protocol_without_validations)
          program_sr               = create(:service_request_without_validations, protocol_id:  program_protocol.id)
          create(:sub_service_request_without_validations, service_request_id:  program_sr.id, organization_id: program_organization.id)

          identity                 = create(:identity)
          create(:service_provider, identity: identity, organization: institution_organization)
          create(:super_user, identity: identity, organization: provider_organization)

          orgs_with_protocols = []
          orgs_with_protocols << provider_organization.id # There is a protocol attached at the provider level
          orgs_with_protocols << program_organization.id # There is a protocol attached at the program level

          # Identity is not a general user, expect an empty array
          expect(Dashboard::IdentityOrganizations.new(identity.id).general_user_organizations_with_protocols.map(&:id)).to eq([])
        end
      end
    end
    context "Identity is a general user" do
      it "should return organizations that general user has access to through protocols" do
        identity                 = create(:identity)

        institution_organization = create(:institution_without_validations)
        provider_organization    = create(:provider_without_validations, parent_id:  institution_organization.id)
        program_organization     = create(:program_without_validations, parent_id: provider_organization.id)

        provider_protocol        = create(:protocol_without_validations, primary_pi: identity)
        provider_sr              = create(:service_request_without_validations, protocol_id:  provider_protocol.id)
        create(:sub_service_request_without_validations, service_request_id:  provider_sr.id, organization_id: provider_organization.id)

        program_protocol         = create(:protocol_without_validations, primary_pi: identity)
        program_sr               = create(:service_request_without_validations, protocol_id:  program_protocol.id)
        create(:sub_service_request_without_validations, service_request_id:  program_sr.id, organization_id: program_organization.id)

        orgs_with_protocols = []
        orgs_with_protocols << provider_organization.id
        orgs_with_protocols << program_organization.id

        # Identity is a general user and has access to both protocols
        expect(Dashboard::IdentityOrganizations.new(identity.id).general_user_organizations_with_protocols.map(&:id)).to eq(orgs_with_protocols.flatten.sort)
      end
    end
    context "Identity is a general user" do
      it "should return organizations that general user has access to through protocols" do
        identity                 = create(:identity)

        institution_organization = create(:institution_without_validations)
        provider_organization    = create(:provider_without_validations, parent_id:  institution_organization.id)
        program_organization     = create(:program_without_validations, parent_id: provider_organization.id)
        core_organization        = create(:core_without_validations, parent_id: program_organization.id)

        provider_protocol        = create(:protocol_without_validations, primary_pi: identity)
        provider_sr              = create(:service_request_without_validations, protocol_id:  provider_protocol.id)
        create(:sub_service_request_without_validations, service_request_id:  provider_sr.id, organization_id: provider_organization.id)

        program_protocol         = create(:protocol_without_validations, primary_pi: identity)
        program_sr               = create(:service_request_without_validations, protocol_id:  program_protocol.id)
        create(:sub_service_request_without_validations, service_request_id:  program_sr.id, organization_id: program_organization.id)

        unattached_protocol      = create(:protocol_without_validations)
        unattached_provider_sr   = create(:service_request_without_validations, protocol_id:  unattached_protocol.id)
        create(:sub_service_request_without_validations, service_request_id:  unattached_provider_sr.id, organization_id: core_organization.id)

        orgs_with_protocols = []
        orgs_with_protocols << provider_organization.id
        orgs_with_protocols << program_organization.id

        # Identity is a general user and has access to both protocols
        expect(Dashboard::IdentityOrganizations.new(identity.id).general_user_organizations_with_protocols.map(&:id)).to eq(orgs_with_protocols.flatten.sort)
      end
    end
  end
end
