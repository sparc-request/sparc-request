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

RSpec.describe Admin::IdentitiesController do
      
  describe 'user is not logged in and, thus, has no access to' do
    it 'index' do
      get(:index, {:format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end

    it 'search' do
      get(:search, {:term => "abcd", :format => :json})
      expect(response.status).to eq(401)
    end
    
    it 'create' do
      expect {
        post(:create, {:format => :json,
          :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
        })
        expect(response.status).to eq(401)
      }.to change(Identity, :count).by(0)
    end
    
    it 'show' do 
      get(:show, {:id => 1, :format => :json})
      expect(response.status).to eq(401)
    end
   
    it 'update' do
      put(:update, {:id => 1, :format => :json})
      expect(response.status).to eq(401)
    end
  end

  describe 'authenticated identity' do
    before :each do
      @identity = Identity.new
      @identity.first_name = "Jane"
      @identity.last_name = "Doe"
      @identity.email = "janedoe@techu.edu"
      @identity.ldap_uid = "jdoe@techu.edu"
      @identity.approved = true
      @identity.save(validate: false)
      session[:identity_id] = @identity.id
      # Devise test helper method: sign_in
      sign_in @identity
    end
   
    describe 'is not a service_provider or super_user and, thus,' do
      describe 'should have access to' do
        it 'index' do 
          get(:index, {:format => :html})
          expect(response.status).to eq(200)
          expect(response).to render_template("index")
        end
       
        it 'search' do
          allow(Directory).to receive(:search_and_merge_ldap_and_database_results) { [] }
          get(:search, {:term => "abcd", :format => :json})
          expect(response.status).to eq(200)
          expect(response.body).to eq("[]")
        end
        
        it 'search and view results that includes data merged from database and LDAP' do
          database_user = Identity.new(ldap_uid: "jsmith@musc.edu", first_name: "John", last_name: "Smith", email: "johnsmith@musc.edu")
          database_user.save(validate: false)
          
          ldap_user = Hash.new
          ldap_user['sn'] = ["Smith"]
          ldap_user['givenname'] = ["John"]
          ldap_user['mail'] = ["johnsmith@musc.edu"]
          ldap_user['uid'] = ["jsmith"]
            
          ldap_user_two = Hash.new
          ldap_user_two['sn'] = ["Doe"]
          ldap_user_two['givenname'] = ["Jane"]
          ldap_user_two['mail'] = ["janedoe@musc.edu"]
          ldap_user_two['uid'] = ["jdoe"]

          allow(Directory).to receive(:search_database) { [ database_user ]}
          allow(Directory).to receive(:search_ldap) { [ ldap_user, ldap_user_two ] }
          
          get(:search, {:term => "abcd", :format => :json})
          expect(response.status).to eq(200)

          # record found in both the database and LDAP has an "id" value
          expect(JSON.parse(response.body)[0]).to include("id" => database_user.id, "first_name" => "John", "last_name" => "Smith", 
                                                          "email" => "johnsmith@musc.edu", "ldap_uid" => "jsmith@musc.edu") 
          # record found only in LDAP should not have an "id" field
          expect(JSON.parse(response.body)[1]).to include("id" => nil, "first_name" => "Jane", "last_name" => "Doe", 
                                                          "email" => "janedoe@musc.edu", "ldap_uid" => "jdoe@musc.edu")
        end
        
        it 'create' do
          expect {
            post(:create, {:format => :json,
              :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
            })
            expect(response.status).to eq(200)
            new_identity = Identity.where(email: "johnsmith@techu.edu").first
            expect(new_identity.approved).to eq(true)
            expect(new_identity.encrypted_password).not_to be_blank
            expect(JSON.parse(response.body)).to include("id" => new_identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                         "email" => "johnsmith@techu.edu", "ldap_uid" => "jsmith@techu.edu") 
          }.to change(Identity, :count).by(1)
        end
      end
      
      describe 'should NOT have access to' do
        it 'show' do 
          get(:show, {:id => @identity, :format => :json})
          expect(response.status).to eq(401)
        end
       
        it 'update' do
          put(:update, {:id => 1, :format => :json})
          expect(response.status).to eq(401)
        end
      end
    end

    describe 'is a service provider and, thus,' do
      before :each do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.save(validate: false)
      end
      
      describe 'should have access to' do
        it 'index' do 
          get(:index, {:format => :html})
          expect(response.status).to eq(200)
          expect(response).to render_template("index")
        end
       
        it 'search' do
          allow(Directory).to receive(:search_and_merge_ldap_and_database_results) { [] }
          get(:search, {:term => "abcd", :format => :json})
          expect(response.status).to eq(200)
        end
  
        it 'create' do
          expect {
            post(:create, {:format => :json,
              :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
            })
            expect(response.status).to eq(200)
            new_identity = Identity.where(email: "johnsmith@techu.edu").first
            expect(new_identity.approved).to eq(true)
            expect(new_identity.encrypted_password).not_to be_blank
            expect(JSON.parse(response.body)).to include("id" => new_identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                         "email" => "johnsmith@techu.edu", "ldap_uid" => "jsmith@techu.edu") 
          }.to change(Identity, :count).by(1)
        end
      end
      
      describe 'should NOT have access to' do
        it 'show' do 
          get(:show, {:id => @identity, :format => :json})
          expect(response.status).to eq(401)
        end
       
        it 'update' do
          put(:update, {:id => 1, :format => :json})
          expect(response.status).to eq(401)
        end
      end
    end
    
    describe 'is a super_user and, thus, should have access to' do
      before :each do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.save(validate: false)
      end
      
      it 'index' do 
        get(:index, {:format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("index")
      end
     
      it 'search' do
        allow(Directory).to receive(:search_and_merge_ldap_and_database_results) { [] }
        get(:search, {:term => "abcd", :format => :json})
        expect(response.status).to eq(200)
      end
      
      it 'create' do
        expect {
          post(:create, {:format => :json,
            :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
          })
          expect(response.status).to eq(200)
          new_identity = Identity.where(email: "johnsmith@techu.edu").first
          expect(new_identity.approved).to eq(true)
          expect(new_identity.encrypted_password).not_to be_blank
          expect(JSON.parse(response.body)).to include("id" => new_identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                       "email" => "johnsmith@techu.edu", "ldap_uid" => "jsmith@techu.edu") 
        }.to change(Identity, :count).by(1)
      end
      
      it 'create and messages for failed validation' do
        expect {
          post(:create, {:format => :json,
            :identity => {:first_name => "John", :last_name => "", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
          })
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)).to include("last_name" => ["can't be blank"])
        }.to change(Identity, :count).by(0)
      end
      
      it 'show' do 
        get(:show, {:id => @identity, :format => :json})
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include("id" => @identity.id, "first_name" => "Jane", "last_name" => "Doe", 
                                                     "email" => "janedoe@techu.edu", "ldap_uid" => "jdoe@techu.edu") 
      end
      
      it 'update (and LDAP_UID should not be allowed to change)' do
        expect {
          put(:update, {:format => :json, :id => @identity,
            :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
          })
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)).to include("id" => @identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                       "email" => "johnsmith@techu.edu", "ldap_uid" => "jdoe@techu.edu")
          updated_identity = Identity.where(ldap_uid: "jdoe@techu.edu").first
          expect(updated_identity.first_name).to eq("John")  
        }.to change(Identity, :count).by(0)
      end
      
      it 'update and messages for failed validation' do
        expect {
          put(:update, {:format => :json, :id => @identity,
            :identity => {:first_name => "", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
          })
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)).to include("first_name" => ["can't be blank"])
          updated_identity = Identity.where(ldap_uid: "jdoe@techu.edu").first
          expect(updated_identity.first_name).to eq("Jane") 
        }.to change(Identity, :count).by(0)
      end
      
      it '404s for a bogus identity id' do
        get(:show, {:id => 23234234, :format => :json})        
        expect(response.status).to eq(404)
        expect(response.body).to eq("")
        
        put(:update, {:format => :json, :id => 23234234,
          :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
        })
        expect(response.status).to eq(404)
        expect(response.body).to eq("")
      end
    end
    
    describe 'is only a catalog_manager and, thus,' do
      before :each do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.save(validate: false)
      end
      
      describe 'should have access to' do
        it 'index' do 
          get(:index, {:format => :html})
          expect(response.status).to eq(200)
          expect(response).to render_template("index")
        end
       
        it 'search' do
          allow(Directory).to receive(:search_and_merge_ldap_and_database_results) { [] }
          get(:search, {:term => "abcd", :format => :json})
          expect(response.status).to eq(200)
        end
        
        it 'create' do
          expect {
            post(:create, {:format => :json,
              :identity => {:first_name => "John", :last_name => "Smith", :email => "johnsmith@techu.edu", :ldap_uid => "jsmith@techu.edu"}
            })
            expect(response.status).to eq(200)
            new_identity = Identity.where(email: "johnsmith@techu.edu").first
            expect(new_identity.approved).to eq(true)
            expect(new_identity.encrypted_password).not_to be_blank
            expect(JSON.parse(response.body)).to include("id" => new_identity.id, "first_name" => "John", "last_name" => "Smith", 
                                                         "email" => "johnsmith@techu.edu", "ldap_uid" => "jsmith@techu.edu") 
          }.to change(Identity, :count).by(1)
        end
      end
      
      describe 'should NOT have access to' do
        it 'show' do 
          get(:show, {:id => @identity, :format => :json})
          expect(response.status).to eq(401)
        end
       
        it 'update' do
          put(:update, {:id => 1, :format => :json})
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
