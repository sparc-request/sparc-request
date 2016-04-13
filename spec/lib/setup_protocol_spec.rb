require 'rails_helper'

RSpec.describe SetupProtocol, type: :model do 

  describe '#set_portal' do

    it 'should return true' do
      portal = 'true'
      identity = build_stubbed(:identity)
      protocol = build_stubbed(:protocol, identity: identity)
      service_request = build_stubbed(:service_request, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).set_portal

      expect(response).to eq 'true'
    end

    it 'should return false' do
      portal = 'false'
      identity = build_stubbed(:identity)
      protocol = build_stubbed(:protocol, identity: identity)
      service_request = build_stubbed(:service_request, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).set_portal

      expect(response).to eq 'false'
    end
  end

  describe '#find_service_request' do

    it 'should return the correct service request' do
      portal = 'false'
      identity = create(:identity)
      protocol = create(:protocol, :without_validations, identity: identity)
      service_request = create(:service_request, :without_validations, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).find_service_request

      expect(response).to eq service_request
    end
    
    it 'should return nil' do
      portal = 'true'
      identity = create(:identity)
      protocol = create(:protocol, :without_validations, identity: identity)
      service_request = create(:service_request, :without_validations, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).find_service_request

      expect(response).to eq nil
    end
  end

  describe '#requester_id' do

    it 'should return the correct requester id' do
      portal = 'true'
      identity = create(:identity)
      protocol = create(:protocol, :without_validations, identity: identity)
      service_request = create(:service_request, :without_validations, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).requester_id

      expect(response).to eq identity.id
    end
  end
end

