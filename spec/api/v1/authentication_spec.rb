require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'authentication' do

    before do
      @protocol = FactoryGirl.build(:protocol)
      @protocol.save validate: false
    end

    context 'success' do

      before { cwf_sends_api_get_request_for_resource('protocols', @protocol.id, 'shallow') }

      it 'should allow the request' do
        expect(response.code).to eq('200')
      end
    end

    context 'failure' do

      context 'bad username' do

        before do
          bad_username = 'bad_username'

          http_login(bad_username, REMOTE_SERVICE_NOTIFIER_PASSWORD)

          get "/v1/protocols/#{@protocol.id}.json", @env
        end

        it 'should not allow the request' do
          expect(response.code).to eq('401')
        end

        it 'should not respond' do
          expect(response.body).to be_empty
        end
      end

      context 'bad password' do

        before do
          bad_password = 'bad_password'

          http_login(REMOTE_SERVICE_NOTIFIER_USERNAME, bad_password)

          get "/v1/protocols/#{@protocol.id}.json", @env
        end

        it 'should not allow the request' do
          expect(response.code).to eq('401')
        end

        it 'should not respond' do
          expect(response.body).to be_empty
        end
      end
    end
  end
end
