require 'rails_helper'

RSpec.describe LockedOrganizationsController, type: :controller do
  stub_controller

  describe '#show' do

    it 'should return a success status' do
      identity = create(:identity)
      organization = create(:organization)
      create(:service_provider,
             :is_primary_contact,
             organization: organization,
             identity_id: identity.id
            )
      protocol = create(:protocol, :without_validations)
      sr = create(:service_request, :without_validations)
      create(:sub_service_request,
             :without_validations,
             service_request: sr,
             organization: organization
            )

      get :show, params: {
        org_id: organization.id,
        protocol_id: protocol.id,
        service_request_id: sr.id
        }, xhr: true


      expect(response).to be_success
    end

    it 'should return Identity' do
      identity = create(:identity)
      organization = create(:organization)
      create(:service_provider,
             :is_primary_contact,
             organization: organization,
             identity_id: identity.id
            )
      protocol = create(:protocol, :without_validations)
      sr = create(:service_request, :without_validations)
      create(:sub_service_request,
             :without_validations,
             service_request: sr,
             organization: organization
            )

      get :show, params: {
        org_id: organization.id,
        protocol_id: protocol.id,
        service_request_id: sr.id
        }, xhr: true


      expect(assigns(:identity)).to eq identity
    end

    it 'should return Organization' do
      identity = create(:identity)
      organization = create(:organization)
      create(:service_provider,
             :is_primary_contact,
             organization: organization,
             identity_id: identity.id
            )
      protocol = create(:protocol, :without_validations)
      sr = create(:service_request, :without_validations)
      create(:sub_service_request,
             :without_validations,
             service_request: sr,
             organization: organization
            )

      get :show, params: {
        org_id: organization.id,
        protocol_id: protocol.id,
        service_request_id: sr.id
        }, xhr: true


      expect(assigns(:organization)).to eq organization
    end

    it 'should return Service Provider' do
      identity = create(:identity)
      organization = create(:organization)
      sp = create(:service_provider,
             :is_primary_contact,
             organization: organization,
             identity_id: identity.id
            )
      protocol = create(:protocol, :without_validations)
      sr = create(:service_request, :without_validations)
      create(:sub_service_request,
             :without_validations,
             service_request: sr,
             organization: organization
            )

      get :show, params: {
        org_id: organization.id,
        protocol_id: protocol.id,
        service_request_id: sr.id
        }, xhr: true


      expect(assigns(:service_provider)).to eq sp
    end

    it 'should return Protocol' do
      identity = create(:identity)
      organization = create(:organization)
      sp = create(:service_provider,
             :is_primary_contact,
             organization: organization,
             identity_id: identity.id
            )
      protocol = create(:protocol, :without_validations)
      sr = create(:service_request, :without_validations)
      create(:sub_service_request,
             :without_validations,
             service_request: sr,
             organization: organization
            )

      get :show, params: {
        org_id: organization.id,
        protocol_id: protocol.id,
        service_request_id: sr.id
        }, xhr: true


      expect(assigns(:protocol)).to eq protocol
    end

    it 'should return SSR' do
      identity = create(:identity)
      organization = create(:organization)
      create(:service_provider,
             :is_primary_contact,
             organization: organization,
             identity_id: identity.id
            )
      protocol = create(:protocol, :without_validations)
      sr = create(:service_request, :without_validations)
      ssr = create(:sub_service_request,
             :without_validations,
             service_request: sr,
             organization: organization
            )

      get :show, params: {
        org_id: organization.id,
        protocol_id: protocol.id,
        service_request_id: sr.id
        }, xhr: true


      expect(assigns(:ssr)).to eq ssr
    end
  end
end

