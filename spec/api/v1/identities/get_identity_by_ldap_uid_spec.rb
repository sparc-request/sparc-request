require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do
  
  describe 'GET /v1/identities.json' do
    before do
      FactoryGirl.create_list(:identity, 5)
    end
    
    context ':shallow record,' do
       context 'valid ldap_uid' do
        before do
          @identity = Identity.first
          params = { :depth => 'shallow',
                     :limit => 1,
                     :query => { ldap_uid: @identity.ldap_uid } 
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params) 
        end
        it 'should respond with a single identity' do
          expect(response.status).to eq(200)
          parsed_body         = JSON.parse(response.body)
          expected_attributes = ['callback_url', 'sparc_id']

          expect(parsed_body['identity'].keys.sort).to eq(expected_attributes)
          expect(parsed_body['identity']['sparc_id']).to eq(@identity.id)
        end
      end
      
      context 'empty ldap_uid' do
       before do
         @identity = Identity.first
         params = { :depth => 'shallow',
                    :limit => 1,
                    :query => { ldap_uid: "" } 
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params) 
       end
       it 'should respond with an error' do
         expect(response.status).to eq(200)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("Identity not found for query #<Hashie::Mash ldap_uid=\"\">")
       end
     end
     
     context 'ldap_uid not found' do
      before do
        @identity = Identity.first
        params = { :depth => 'shallow',
                   :limit => 1,
                   :query => { ldap_uid: "asdfasdfasdfasdfasdf" } 
                 }
         cwf_sends_api_get_request_for_resources_by_params('identities', params) 
      end
      it 'should respond with an error' do
        expect(response.status).to eq(200)
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['identity']).to eq(nil)
        expect(parsed_body['error']).to eq("Identity not found for query #<Hashie::Mash ldap_uid=\"asdfasdfasdfasdfasdf\">")
      end
    end
    
    context 'query member field is not valid' do
       before do
         @identity = Identity.first
         params = { :depth => 'shallow',
                    :limit => 1,
                    :query => { ldap_uiddddddddd: @identity.ldap_uid } 
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params) 
       end
       it 'should respond with an error of "no such column"' do
         expect(response.status).to eq(200)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\"> has the following invalid parameters: [\"ldap_uiddddddddd\"]")
       end
      end
      
      context 'multiple query member fields are not valid' do
         before do
           @identity = Identity.first
           params = { :depth => 'shallow',
                      :limit => 1,
                      :query => { ldap_uiddddddddd: @identity.ldap_uid, naaaammmmee: @identity.first_name } 
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params) 
         end
         it 'should respond with an error of "no such column"' do
           expect(response.status).to eq(200)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identity']).to eq(nil)
           expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\" naaaammmmee=\"#{@identity.first_name}\"> has the following invalid parameters: [\"ldap_uiddddddddd\", \"naaaammmmee\"]")
         end
        end  
      
    context 'query string (not hash) is not valid' do
       before do
         @identity = Identity.first
         params = { :depth => 'shallow',
                    :limit => 1,
                    :query => "asdfadsf"
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params) 
       end
       it 'should respond with an error of "query is invalid"' do
         #expect(response.status).to eq(200)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("query is invalid")
       end
      end
      
      context 'empty query hash' do
         before do
           @identity = Identity.first
           params = { :depth => 'shallow',
                      :limit => 1,
                      :query => {}
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params) 
         end
         it 'should respond with all identities' do
           expect(response.status).to eq(200)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identities'].length).to eq(5)
         end
       end
     
       context 'limit not specified' do
        before do
          @identity = Identity.first
          params = { :depth => 'shallow',
                   #  :limit => 1,
                     :query => { ldap_uid: @identity.ldap_uid } 
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params) 
        end
        it 'should respond with all identities' do
          expect(response.status).to eq(200)
          parsed_body         = JSON.parse(response.body)
          expect(parsed_body['identities'].length).to eq(5)
        end
      end
    end
    
    context ':full record,' do
      context 'valid ldap_uid' do
        before do
          @identity = Identity.first
          params = { :depth => 'full',
                     :limit => 1,
                     :query => { ldap_uid: @identity.ldap_uid } 
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params) 
        end
        it 'should respond with a single identity plus attributes' do
          expect(response.status).to eq(200)
          parsed_body         = JSON.parse(response.body)
          expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid'].
                                  push('callback_url', 'sparc_id').
                                  sort

          expect(parsed_body['identity'].keys.sort).to eq(expected_attributes)
          expect(parsed_body['identity']['ldap_uid']).to eq(@identity.ldap_uid)
        end
      end
    end
    
    context ':full_with_shallow_reflections,' do
      context 'valid ldap_uid' do
        before do
          @identity = Identity.first
          params = { :depth => 'full_with_shallow_reflections',
                     :limit => 1,
                     :query => { ldap_uid: @identity.ldap_uid } 
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params) 
        end
        it 'should respond with a single identity plus attributes and shallow reflections of protocols' do
          expect(response.status).to eq(200)
          parsed_body         = JSON.parse(response.body)
          expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                  push('callback_url', 'sparc_id').
                                  sort
          expect(parsed_body['identity'].keys.sort).to eq(expected_attributes)
          expect(parsed_body['identity']['ldap_uid']).to eq(@identity.ldap_uid)
          expect(parsed_body['identity']['protocols'].length).to eq(0)
        end
      end
  end
  end
end
