# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/identities.json' do
    before do
      FactoryGirl.create_list(:identity, 5)
    end
    ##################################
    # Shallow records
    ##################################
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

      context 'valid ldap_uid and limit not specified' do
       before do
         @identity = Identity.first
         params = { :depth => 'shallow',
                  #  :limit => 1,
                    :query => { ldap_uid: @identity.ldap_uid }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with a list of identities with a length of one' do
         expect(response.status).to eq(200)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identities'].length).to eq(1)

         expected_attributes = ['callback_url', 'sparc_id']
         expect(parsed_body['identities'][0].keys.sort).to eq(expected_attributes)
         expect(parsed_body['identities'][0]['sparc_id']).to eq(@identity.id)
       end
     end

     context 'valid query by institution that should return all rows and limit is three' do
       before do
         # update all identities to have the same institution
         Identity.all.each do |identity|
           identity.institution = "U of Institution"
           identity.save
         end

         params = { :depth => 'shallow',
                    :limit => 3,
                    :query => { institution: "U of Institution" }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with a list of identities with a length of three and the first has five protocols' do
         expect(response.status).to eq(200)
         parsed_body         = JSON.parse(response.body)
         expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                 push('callback_url', 'sparc_id').
                                 sort
         expect(parsed_body['identities'].length).to eq(3)
       end
     end

      context 'empty ldap_uid' do
       before do
         params = { :depth => 'shallow',
                    :limit => 1,
                    :query => { ldap_uid: "" }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with an error' do
         expect(response.status).to eq(404)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("Identity not found for query #<Hashie::Mash ldap_uid=\"\">")
       end
     end

     context 'empty ldap_uid and limit not specified' do
      before do
        params = { :depth => 'shallow',
                  # :limit => 1,
                   :query => { ldap_uid: "" }
                 }
         cwf_sends_api_get_request_for_resources_by_params('identities', params)
      end
      it 'should respond with an error' do
        expect(response.status).to eq(200)
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['identities'].length).to eq(0)
      end
    end

     context 'ldap_uid not found' do
      before do
        params = { :depth => 'shallow',
                   :limit => 1,
                   :query => { ldap_uid: "asdfasdfasdfasdfasdf" }
                 }
         cwf_sends_api_get_request_for_resources_by_params('identities', params)
      end
      it 'should respond with an error' do
        expect(response.status).to eq(404)
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['identity']).to eq(nil)
        expect(parsed_body['error']).to eq("Identity not found for query #<Hashie::Mash ldap_uid=\"asdfasdfasdfasdfasdf\">")
      end
    end

    context 'ldap_uid not found and limit not specified' do
     before do
       params = { :depth => 'shallow',
             #     :limit => 1,
                  :query => { ldap_uid: "asdfasdfasdfasdfasdf" }
                }
        cwf_sends_api_get_request_for_resources_by_params('identities', params)
     end
     it 'should respond with an error' do
       expect(response.status).to eq(200)
       parsed_body         = JSON.parse(response.body)
       expect(parsed_body['identities'].length).to eq(0)
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
         expect(response.status).to eq(400)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\"> has the following invalid parameters: [\"ldap_uiddddddddd\"]")
       end
      end


      context 'query member field is not valid and limit not specified' do
         before do
           @identity = Identity.first
           params = { :depth => 'shallow',
                   #   :limit => 1,
                      :query => { ldap_uiddddddddd: @identity.ldap_uid }
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "no such column"' do
           expect(response.status).to eq(400)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identities']).to eq(nil)
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
           expect(response.status).to eq(400)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identity']).to eq(nil)
           expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\" naaaammmmee=\"#{@identity.first_name}\"> has the following invalid parameters: [\"ldap_uiddddddddd\", \"naaaammmmee\"]")
         end
        end

        context 'multiple query member fields are not valid and limit not specified' do
           before do
             @identity = Identity.first
             params = { :depth => 'shallow',
                       # :limit => 1,
                        :query => { ldap_uiddddddddd: @identity.ldap_uid, naaaammmmee: @identity.first_name }
                      }
              cwf_sends_api_get_request_for_resources_by_params('identities', params)
           end
           it 'should respond with an error of "no such column"' do
             expect(response.status).to eq(400)
             parsed_body         = JSON.parse(response.body)
             expect(parsed_body['identities']).to eq(nil)
             expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\" naaaammmmee=\"#{@identity.first_name}\"> has the following invalid parameters: [\"ldap_uiddddddddd\", \"naaaammmmee\"]")
           end
          end

    context 'query as type String is not valid, must be a Hash' do
       before do
         params = { :depth => 'shallow',
                    :limit => 1,
                    :query => "asdfadsf"
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with an error of "query is invalid"' do
         expect(response.status).to eq(400)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("query is invalid")
       end
      end

      context 'query as type String is not valid, must be a Hash, and limit not specified' do
         before do
           params = { :depth => 'shallow',
                     # :limit => 1,
                      :query => "asdfadsf"
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "query is invalid"' do
           expect(response.status).to eq(400)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identities']).to eq(nil)
           expect(parsed_body['error']).to eq("query is invalid")
         end
        end

      context 'empty query hash' do
         before do
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

       context 'empty query hash and limit not specified' do
          before do
            params = { :depth => 'shallow',
                  #     :limit => 1,
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
    end
    ##################################
    # Full records
    ##################################
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

      context 'valid ldap_uid and limit not specified' do
       before do
         @identity = Identity.first
         params = { :depth => 'full',
                  #  :limit => 1,
                    :query => { ldap_uid: @identity.ldap_uid }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with a list of identities with a length of one' do
         expect(response.status).to eq(200)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identities'].length).to eq(1)
         expect(parsed_body['identities'][0]['ldap_uid']).to eq(@identity.ldap_uid)
         expect(parsed_body['identities'][0]['first_name']).to eq(@identity.first_name)
         expect(parsed_body['identities'][0]['last_name']).to eq(@identity.last_name)
         expect(parsed_body['identities'][0]['email']).to eq(@identity.email)
       end
     end

     context 'valid query by institution that should return all rows and limit is three' do
       before do
         @identity = Identity.first
         # update all identities to have the same institution
         Identity.all.each do |identity|
           identity.institution = "U of Institution"
           identity.save
         end

         params = { :depth => 'full',
                    :limit => 3,
                    :query => { institution: "U of Institution" }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with a list of identities with a length of three and the first has five protocols' do
         expect(response.status).to eq(200)
         parsed_body         = JSON.parse(response.body)
         expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                 push('callback_url', 'sparc_id').
                                 sort
         expect(parsed_body['identities'].length).to eq(3)
         expect(parsed_body['identities'][0]['ldap_uid']).to eq(@identity.ldap_uid)
         expect(parsed_body['identities'][0]['first_name']).to eq(@identity.first_name)
         expect(parsed_body['identities'][0]['last_name']).to eq(@identity.last_name)
         expect(parsed_body['identities'][0]['email']).to eq(@identity.email)
       end
     end

      context 'empty ldap_uid' do
       before do
         params = { :depth => 'full',
                    :limit => 1,
                    :query => { ldap_uid: "" }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with an error' do
         expect(response.status).to eq(404)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("Identity not found for query #<Hashie::Mash ldap_uid=\"\">")
       end
     end

     context 'empty ldap_uid and limit not specified' do
      before do
        params = { :depth => 'full',
                 #  :limit => 1,
                   :query => { ldap_uid: "" }
                 }
         cwf_sends_api_get_request_for_resources_by_params('identities', params)
      end
      it 'should respond with an error' do
        expect(response.status).to eq(200)
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['identities'].length).to eq(0)
      end
    end

    context 'ldap_uid not found' do
     before do
       params = { :depth => 'full',
                  :limit => 1,
                  :query => { ldap_uid: "asdfasdfasdfasdfasdf" }
                }
        cwf_sends_api_get_request_for_resources_by_params('identities', params)
     end
     it 'should respond with an error' do
       expect(response.status).to eq(404)
       parsed_body         = JSON.parse(response.body)
       expect(parsed_body['identity']).to eq(nil)
       expect(parsed_body['error']).to eq("Identity not found for query #<Hashie::Mash ldap_uid=\"asdfasdfasdfasdfasdf\">")
     end
   end


     context 'ldap_uid not found and limit not specified' do
      before do
        params = { :depth => 'full',
             #      :limit => 1,
                   :query => { ldap_uid: "asdfasdfasdfasdfasdf" }
                 }
         cwf_sends_api_get_request_for_resources_by_params('identities', params)
      end
      it 'should respond with an error' do
        expect(response.status).to eq(200)
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['identities'].length).to eq(0)
      end
    end

    context 'query member field is not valid' do
       before do
         @identity = Identity.first
         params = { :depth => 'full',
                    :limit => 1,
                    :query => { ldap_uiddddddddd: @identity.ldap_uid }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with an error of "no such column"' do
         expect(response.status).to eq(400)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\"> has the following invalid parameters: [\"ldap_uiddddddddd\"]")
       end
      end

      context 'query member field is not valid and limit not specified' do
         before do
           @identity = Identity.first
           params = { :depth => 'full',
                    #  :limit => 1,
                      :query => { ldap_uiddddddddd: @identity.ldap_uid }
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "no such column"' do
           expect(response.status).to eq(400)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identities']).to eq(nil)
           expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\"> has the following invalid parameters: [\"ldap_uiddddddddd\"]")
         end
        end

        context 'multiple query member fields are not valid' do
           before do
             @identity = Identity.first
             params = { :depth => 'full',
                        :limit => 1,
                        :query => { ldap_uiddddddddd: @identity.ldap_uid, naaaammmmee: @identity.first_name }
                      }
              cwf_sends_api_get_request_for_resources_by_params('identities', params)
           end
           it 'should respond with an error of "no such column"' do
             expect(response.status).to eq(400)
             parsed_body         = JSON.parse(response.body)
             expect(parsed_body['identity']).to eq(nil)
             expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\" naaaammmmee=\"#{@identity.first_name}\"> has the following invalid parameters: [\"ldap_uiddddddddd\", \"naaaammmmee\"]")
           end
          end

      context 'multiple query member fields are not valid and limit not specified' do
         before do
           @identity = Identity.first
           params = { :depth => 'full',
                  #    :limit => 1,
                      :query => { ldap_uiddddddddd: @identity.ldap_uid, naaaammmmee: @identity.first_name }
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "no such column"' do
           expect(response.status).to eq(400)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identities']).to eq(nil)
           expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\" naaaammmmee=\"#{@identity.first_name}\"> has the following invalid parameters: [\"ldap_uiddddddddd\", \"naaaammmmee\"]")
         end
        end

      context 'query as type String is not valid, must be a Hash' do
         before do
           params = { :depth => 'full',
                    :limit => 1,
                    :query => "asdfadsf"
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "query is invalid"' do
           expect(response.status).to eq(400)
          parsed_body         = JSON.parse(response.body)
          expect(parsed_body['identity']).to eq(nil)
          expect(parsed_body['error']).to eq("query is invalid")
         end
      end

      context 'query as type String is not valid, must be a Hash, and limit not specified' do
         before do
           params = { :depth => 'full',
                  #  :limit => 1,
                    :query => "asdfadsf"
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "query is invalid"' do
           expect(response.status).to eq(400)
          parsed_body         = JSON.parse(response.body)
          expect(parsed_body['identities']).to eq(nil)
          expect(parsed_body['error']).to eq("query is invalid")
         end
      end

      context 'empty query hash' do
         before do
           params = { :depth => 'full',
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

       context 'empty query hash and limit not specified' do
          before do
            params = { :depth => 'full',
                    #   :limit => 1,
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

    end
    ##################################
    # Full records with shallow reflections
    ##################################
    context ':full_with_shallow_reflections,' do
      ##################################
      # zero protocols
      ##################################
      context 'valid ldap_uid with zero protocols' do
        before do
          @identity = Identity.first
          params = { :depth => 'full_with_shallow_reflections',
                     :limit => 1,
                     :query => { ldap_uid: @identity.ldap_uid }
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params)
        end
        it 'should respond with a single identity plus attributes and a list of zero protocols' do
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

      context 'valid ldap_uid with zero protocols and limit not specified' do
       before do
         @identity = Identity.first
         params = { :depth => 'full_with_shallow_reflections',
                  #  :limit => 1,
                    :query => { ldap_uid: @identity.ldap_uid }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with a list of identities with a length of one' do
         expect(response.status).to eq(200)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identities'].length).to eq(1)
         expect(parsed_body['identities'][0]['ldap_uid']).to eq(@identity.ldap_uid)
         expect(parsed_body['identities'][0]['first_name']).to eq(@identity.first_name)
         expect(parsed_body['identities'][0]['last_name']).to eq(@identity.last_name)
         expect(parsed_body['identities'][0]['email']).to eq(@identity.email)
         expect(parsed_body['identities'][0]['protocols'].length).to eq(0)
       end
     end

      context 'empty ldap_uid' do
       before do
         params = { :depth => 'full_with_shallow_reflections',
                    :limit => 1,
                    :query => { ldap_uid: "" }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with an error' do
         expect(response.status).to eq(404)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("Identity not found for query #<Hashie::Mash ldap_uid=\"\">")
       end
     end

     context 'empty ldap_uid and limit not specified' do
      before do
        params = { :depth => 'full_with_shallow_reflections',
                #   :limit => 1,
                   :query => { ldap_uid: "" }
                 }
         cwf_sends_api_get_request_for_resources_by_params('identities', params)
      end
      it 'should respond with an error' do
        expect(response.status).to eq(200)
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['identities'].length).to eq(0)
      end
    end

     context 'ldap_uid not found' do
      before do
        params = { :depth => 'full_with_shallow_reflections',
                   :limit => 1,
                   :query => { ldap_uid: "asdfasdfasdfasdfasdf" }
                 }
         cwf_sends_api_get_request_for_resources_by_params('identities', params)
      end
      it 'should respond with an error' do
        expect(response.status).to eq(404)
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['identity']).to eq(nil)
        expect(parsed_body['error']).to eq("Identity not found for query #<Hashie::Mash ldap_uid=\"asdfasdfasdfasdfasdf\">")
      end
    end

    context 'ldap_uid not found and limit not specified' do
     before do
       params = { :depth => 'full_with_shallow_reflections',
                #  :limit => 1,
                  :query => { ldap_uid: "asdfasdfasdfasdfasdf" }
                }
        cwf_sends_api_get_request_for_resources_by_params('identities', params)
     end
     it 'should respond with an error' do
       expect(response.status).to eq(200)
       parsed_body         = JSON.parse(response.body)
       expect(parsed_body['identities'].length).to eq(0)
     end
   end

    context 'query member field is not valid' do
       before do
         @identity = Identity.first
         params = { :depth => 'full_with_shallow_reflections',
                    :limit => 1,
                    :query => { ldap_uiddddddddd: @identity.ldap_uid }
                  }
          cwf_sends_api_get_request_for_resources_by_params('identities', params)
       end
       it 'should respond with an error of "no such column"' do
         expect(response.status).to eq(400)
         parsed_body         = JSON.parse(response.body)
         expect(parsed_body['identity']).to eq(nil)
         expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\"> has the following invalid parameters: [\"ldap_uiddddddddd\"]")
       end
      end

      context 'query member field is not valid and limit not specified' do
         before do
           @identity = Identity.first
           params = { :depth => 'full_with_shallow_reflections',
                     # :limit => 1,
                      :query => { ldap_uiddddddddd: @identity.ldap_uid }
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "no such column"' do
           expect(response.status).to eq(400)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identities']).to eq(nil)
           expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\"> has the following invalid parameters: [\"ldap_uiddddddddd\"]")
         end
        end

      context 'multiple query member fields are not valid' do
         before do
           @identity = Identity.first
           params = { :depth => 'full_with_shallow_reflections',
                      :limit => 1,
                      :query => { ldap_uiddddddddd: @identity.ldap_uid, naaaammmmee: @identity.first_name }
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "no such column"' do
           expect(response.status).to eq(400)
           parsed_body         = JSON.parse(response.body)
           expect(parsed_body['identity']).to eq(nil)
           expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\" naaaammmmee=\"#{@identity.first_name}\"> has the following invalid parameters: [\"ldap_uiddddddddd\", \"naaaammmmee\"]")
         end
        end

        context 'multiple query member fields are not valid and limit not specified' do
           before do
             @identity = Identity.first
             params = { :depth => 'full_with_shallow_reflections',
                    #    :limit => 1,
                        :query => { ldap_uiddddddddd: @identity.ldap_uid, naaaammmmee: @identity.first_name }
                      }
              cwf_sends_api_get_request_for_resources_by_params('identities', params)
           end
           it 'should respond with an error of "no such column"' do
             expect(response.status).to eq(400)
             parsed_body         = JSON.parse(response.body)
             expect(parsed_body['identities']).to eq(nil)
             expect(parsed_body['error']).to eq("Identity query #<Hashie::Mash ldap_uiddddddddd=\"#{@identity.ldap_uid}\" naaaammmmee=\"#{@identity.first_name}\"> has the following invalid parameters: [\"ldap_uiddddddddd\", \"naaaammmmee\"]")
           end
          end

      context 'query as type String is not valid, must be a Hash' do
         before do
           params = { :depth => 'full_with_shallow_reflections',
                    :limit => 1,
                    :query => "asdfadsf"
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "query is invalid"' do
           expect(response.status).to eq(400)
          parsed_body         = JSON.parse(response.body)
          expect(parsed_body['identity']).to eq(nil)
          expect(parsed_body['error']).to eq("query is invalid")
         end
      end

      context 'query as type String is not valid, must be a Hash, and limit not specified' do
         before do
           params = { :depth => 'full_with_shallow_reflections',
                   # :limit => 1,
                    :query => "asdfadsf"
                    }
            cwf_sends_api_get_request_for_resources_by_params('identities', params)
         end
         it 'should respond with an error of "query is invalid"' do
           expect(response.status).to eq(400)
          parsed_body         = JSON.parse(response.body)
          expect(parsed_body['identities']).to eq(nil)
          expect(parsed_body['error']).to eq("query is invalid")
         end
      end

      context 'empty query hash' do
         before do
           params = { :depth => 'full_with_shallow_reflections',
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

       context 'empty query hash and limit not specified' do
          before do
            params = { :depth => 'full_with_shallow_reflections',
                     #  :limit => 1,
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

      ##################################
      # Five protocols
      ##################################
      context 'valid ldap_uid with five protocols and limit of one' do
        before do
          @identity = Identity.first
          5.times do
            protocol = FactoryGirl.build(:protocol)
            protocol.save validate: false
            FactoryGirl.create(:project_role_with_identity_and_protocol, identity: @identity, protocol: protocol)
          end

          params = { :depth => 'full_with_shallow_reflections',
                     :limit => 1,
                     :query => { ldap_uid: @identity.ldap_uid }
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params)
        end
        it 'should respond with a single identity plus attributes and a list of five protocols with short titles' do
          expect(response.status).to eq(200)
          parsed_body         = JSON.parse(response.body)
          expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                  push('callback_url', 'sparc_id').
                                  sort
          expect(parsed_body['identity'].keys.sort).to eq(expected_attributes)
          expect(parsed_body['identity']['ldap_uid']).to eq(@identity.ldap_uid)
          expect(parsed_body['identity']['first_name']).to eq(@identity.first_name)
          expect(parsed_body['identity']['last_name']).to eq(@identity.last_name)
          expect(parsed_body['identity']['email']).to eq(@identity.email)
          expect(parsed_body['identity']['protocols'].length).to eq(5)
        end
      end

      context 'valid ldap_uid with five protocols and limit not specified' do
        before do
          @identity = Identity.first
          5.times do
            protocol = FactoryGirl.build(:protocol)
            protocol.save validate: false
            FactoryGirl.create(:project_role_with_identity_and_protocol, identity: @identity, protocol: protocol)
          end

          params = { :depth => 'full_with_shallow_reflections',
                   #  :limit => 1,
                     :query => { ldap_uid: @identity.ldap_uid }
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params)
        end
        it 'should respond with a list of identities with a length of one, plus attributes and a list of five protocols with short titles' do
          expect(response.status).to eq(200)
          parsed_body         = JSON.parse(response.body)
          expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                  push('callback_url', 'sparc_id').
                                  sort
          expect(parsed_body['identities'].length).to eq(1)
          expect(parsed_body['identities'][0].keys.sort).to eq(expected_attributes)
          expect(parsed_body['identities'][0]['ldap_uid']).to eq(@identity.ldap_uid)
          expect(parsed_body['identities'][0]['first_name']).to eq(@identity.first_name)
          expect(parsed_body['identities'][0]['last_name']).to eq(@identity.last_name)
          expect(parsed_body['identities'][0]['email']).to eq(@identity.email)
          expect(parsed_body['identities'][0]['protocols'].length).to eq(5)
        end
      end

      context 'valid ldap_uid with five protocols and limit is three' do

        before do
          @identity = Identity.first
          5.times do
            protocol = FactoryGirl.build(:protocol)
            protocol.save validate: false
            FactoryGirl.create(:project_role_with_identity_and_protocol, identity: @identity, protocol: protocol)
          end

          params = { :depth => 'full_with_shallow_reflections',
                     :limit => 3,
                     :query => { ldap_uid: @identity.ldap_uid }
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params)
        end

        it 'should respond with a list of identities with a length of one, plus attributes and a list of five protocols with short titles' do
          expect(response.status).to eq(200)
          parsed_body         = JSON.parse(response.body)
          expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                  push('callback_url', 'sparc_id').
                                  sort
          expect(parsed_body['identities'].length).to eq(1)
          expect(parsed_body['identities'][0].keys.sort).to eq(expected_attributes)
          expect(parsed_body['identities'][0]['ldap_uid']).to eq(@identity.ldap_uid)
          expect(parsed_body['identities'][0]['first_name']).to eq(@identity.first_name)
          expect(parsed_body['identities'][0]['last_name']).to eq(@identity.last_name)
          expect(parsed_body['identities'][0]['email']).to eq(@identity.email)
          expect(parsed_body['identities'][0]['protocols'].length).to eq(5)
        end
      end

      context 'valid query by institution that should return all rows and limit is three' do
        before do
          @identity = Identity.first
          5.times do
            protocol = FactoryGirl.build(:protocol)
            protocol.save validate: false
            FactoryGirl.create(:project_role_with_identity_and_protocol, identity: @identity, protocol: protocol)
          end
          # update all identities to have the same institution
          Identity.all.each do |identity|
            identity.institution = "U of Institution"
            identity.save
          end

          params = { :depth => 'full_with_shallow_reflections',
                     :limit => 3,
                     :query => { institution: "U of Institution" }
                   }
           cwf_sends_api_get_request_for_resources_by_params('identities', params)
        end
        it 'should respond with a list of identities with a length of three and the first has five protocols' do
          expect(response.status).to eq(200)
          parsed_body         = JSON.parse(response.body)
          expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                  push('callback_url', 'sparc_id').
                                  sort
          expect(parsed_body['identities'].length).to eq(3)
          expect(parsed_body['identities'][0]['protocols'].length).to eq(5)
          expect(parsed_body['identities'][1]['protocols'].length).to eq(0)
          expect(parsed_body['identities'][2]['protocols'].length).to eq(0)
        end
      end
    end
  end
end
