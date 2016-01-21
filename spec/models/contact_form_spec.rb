require 'rails_helper'

RSpec.describe ContactForm, type: :model do

  it {is_expected.to validate_presence_of(:email) }

  it {is_expected.to validate_presence_of(:message) }

  describe 'email validation' do
    context 'with no domain' do
      let(:message) do
        FactoryGirl.build_stubbed(:contact_form, email: 'test')
      end

      it 'should not allow invalid emails' do
        expect(message).not_to be_valid
      end
    end

    context 'with only @ symbol' do
      let(:message) do
        FactoryGirl.build_stubbed(:contact_form, email: 'test@')
      end

      it 'should not allow invalid emails' do
        expect(message).not_to be_valid
      end
    end

    context 'with correct email format' do
      let(:message) do
        FactoryGirl.build_stubbed(:contact_form, email: 'will.t.holt@gmail.com')
      end

      it 'should be valid' do
        expect(message).to be_valid
      end
    end
  end
end
