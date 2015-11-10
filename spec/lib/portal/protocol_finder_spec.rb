require 'rails_helper'

RSpec.describe Portal::ProtocolFinder do

  describe '.protocols' do

    let!(:identity)             { create :identity }
    let!(:default_protocol)     { create :protocol_without_validations }
    let!(:unarchived_protocol)  { create :protocol_without_validations }
    let!(:archived_protocol)    { create :protocol_without_validations,
                                          archived: true }
    before do
      create_list :project_role_approve, 3,
                  protocol: default_protocol,
                  identity: identity
      create_list :project_role_approve, 3,
                  protocol: unarchived_protocol,
                  identity: identity
      create_list :project_role_approve, 3,
                  protocol: archived_protocol,
                  identity: identity
    end

    context 'default_protocol not present' do

      context 'including archived Protocols' do

        let(:params)          { { include_archived: 'true' } }
        let(:protocol_finder) { Portal::ProtocolFinder.new identity, params }

        it 'should return an array of archived and unarchived Protocols' do
          expect(protocol_finder.protocols).to eq([archived_protocol, unarchived_protocol, default_protocol])
        end
      end

      context 'not including archived Protocols' do

        let(:params)          { { include_archived: 'false' } }
        let(:protocol_finder) { Portal::ProtocolFinder.new identity, params }

        it 'should return an array of unarchived Protocols' do
          expect(protocol_finder.protocols).to eq([unarchived_protocol, default_protocol])
        end
      end
    end

    context 'default_protocol present' do

      context 'including archived Protocols' do

        let(:params)          {
                                {
                                  include_archived: 'true',
                                  default_protocol: default_protocol.id
                                }
                              }
        let(:protocol_finder) { Portal::ProtocolFinder.new identity, params }

        it 'should return an array of archived and unarchived Protocols with the default Protocol first' do
          expect(protocol_finder.protocols).to eq([default_protocol, archived_protocol, unarchived_protocol])
        end
      end

      context 'not including archived Protocols' do

        let(:params)          {
                                {
                                  include_archived: 'false',
                                  default_protocol: default_protocol.id
                                }
                              }
        let(:protocol_finder) { Portal::ProtocolFinder.new identity, params }

        it 'should return an array of unarchived Protocols with the default Protocol first' do
          expect(protocol_finder.protocols).to eq([default_protocol, unarchived_protocol])
        end
      end
    end
  end
end
