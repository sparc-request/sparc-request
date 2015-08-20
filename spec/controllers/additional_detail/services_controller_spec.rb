require 'spec_helper'

describe AdditionalDetail::ServicesController do
  
  
  describe 'user is not logged in and, thus, has no access to' do
    it 'index' do
      get(:index, {:format => :html}) 
      response.should redirect_to("/identities/sign_in")
    end
   end
   
  describe 'authenticated identity has access to' do
    before :each do
      @identity = Identity.new
      @identity.approved = true
      @identity.save(validate: false)        
      session[:identity_id] = @identity.id
      # Devise test helper method: sign_in  
      sign_in @identity
    end
    
    it 'index' do
      get(:index, {:format => :html}) 
      response.should render_template("index")
      expect(response.status).to eq(200)
    end
  end

end
