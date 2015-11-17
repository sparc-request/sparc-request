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
  end

  describe 'authenticated identity' do
    before :each do
      @identity = Identity.new
      @identity.approved = true
      @identity.save(validate: false)
      session[:identity_id] = @identity.id
      # Devise test helper method: sign_in
      sign_in @identity
    end
   
    describe 'is not a service_provider or super_user and, thus, has no access to' do
      it 'index' do
        get(:index, {:format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
      end
      
      it 'search' do
        get(:search, {:term => "abcd", :format => :json})
        expect(response.status).to eq(401)
      end
    end

    describe 'is a service provider and, thus, should have access to' do
      before :each do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.save(validate: false)
      end
      
      it 'index' do 
        get(:index, {:format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("index")
      end
     
      it 'search' do
        get(:search, {:term => "abcd", :format => :json})
        expect(response.status).to eq(200)
      end
    end
    
    describe 'is a super_user and, thus, has access to' do
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
        get(:search, {:term => "abcd", :format => :json})
        expect(response.status).to eq(200)
      end
    end
    
    describe 'is only a catalog_manager and, thus, should NOT have access to' do
      before :each do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.save(validate: false)
      end
      
      it 'index' do
        get(:index, {:format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
      end
      
      it 'search' do
        get(:search, {:term => "abcd", :format => :json})
        expect(response.status).to eq(401)
      end
    end
  end
end
