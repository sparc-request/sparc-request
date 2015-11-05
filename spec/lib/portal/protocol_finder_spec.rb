require 'rails_helper'

RSpec.describe Protal::ProtocolFinder do

  describe '.protocols' do

    let(:identity) { create :identity }

    context 'default_protocol not present' do

      it 'should return an array of Protocols' do
        expect()
      end
    end

    context 'default_protocol present' do

    end
  end
end
