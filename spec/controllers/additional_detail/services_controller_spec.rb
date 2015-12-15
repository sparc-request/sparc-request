require 'spec_helper'

RSpec.describe AdditionalDetail::ServicesController do
  
  before :each do
    
    @program = Program.new
    @program.type = "Program"
    @program.save(validate: false)

    @core = Core.new
    @core.type = "Core"
    @core.parent_id = @program.id
    @core.save(validate: false)
    
    @service = Service.new
    @service.organization = @core
    @service.name = "Generic Service"
    @service.save(validate: false)

    @additional_detail = AdditionalDetail.new
    @additional_detail.name = "Test"
    @additional_detail.service_id = @service.id
    @additional_detail.form_definition_json= '{"schema": {"required": ["t","date"] }}'
    @additional_detail.effective_date = Date.today
    @additional_detail.enabled = "true"
    @additional_detail.save
  end
  
  describe 'user is not logged in and, thus, has no access to' do
    it 'index' do
      get(:index, {:format => :html}) 
      expect(response).to redirect_to("/identities/sign_in")
    end
    
    it "show" do
      get(:show, {:id => @service, :id => @additional_detail, :format => :json })
      expect(response.status).to eq(401)
    end
   end
   
  describe 'authenticated identity ' do
    before :each do
      @identity = Identity.new
      @identity.approved = true
      @identity.save(validate: false)        
      session[:identity_id] = @identity.id
      # Devise test helper method: sign_in  
      sign_in @identity
    end
    
    it 'has access to index' do
      get(:index, {:format => :html}) 
      expect(response).to render_template("index")
      expect(response.status).to eq(200)
    end
    
    it 'but NOT access to show' do
      get(:show, {:id => @service, :format => :json })
      expect(response.status).to eq(401)
      
      get(:show, {:id => @service, :format => :html })
      expect(response.status).to eq(401)
      expect(response).to render_template("additional_detail/shared/unauthorized")
    end
    
    it 'should see a 404 for a bogus service id' do
      get(:show, {:id => 2342343, :format => :json })
      expect(response.status).to eq(404)
      expect(response.body).to eq("")
    end
    
    describe 'is a core service provider and' do
      before :each do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)
      end
      
      it 'has access to show with the current additional_detail' do
        get(:show, {:id => @service, :format => :json })
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service.to_json(:root => false, :only => [:name], :include => :current_additional_detail))
      end
      
      it 'has access to show HTML that redirects to additional_details' do
        get(:show, {:id => @service, :format => :html })
        expect(response).to redirect_to(additional_detail_service_additional_details_path(@service))
      end
    end
    
    describe 'is a program service provider and' do
      before :each do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)
      end
      
      it 'has access to show with the current additional_detail' do
        get(:show, {:id => @service, :format => :json })
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service.to_json(:root => false, :only => [:name], :include => :current_additional_detail))
      end
      
      it 'has access to show HTML that redirects to additional_details' do
        get(:show, {:id => @service, :format => :html })
        expect(response).to redirect_to(additional_detail_service_additional_details_path(@service))
      end
    end
    
    describe 'is a catalog_manager for a core and and has access to' do
      before :each do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @core.id
        @catalog_manager.save(validate: false)
      end

      it 'show with the current additional_detail' do
        get(:show, {:id => @service, :format => :json })
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service.to_json(:root => false, :only => [:name], :include => :current_additional_detail))
      end
      
      it 'has access to show HTML that redirects to additional_details' do
        get(:show, {:id => @service, :format => :html })
        expect(response).to redirect_to(additional_detail_service_additional_details_path(@service))
      end
    end
    
    describe 'is a catalog_manager for a program and and has access to' do
      before :each do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false)
      end

      it 'show with the current additional_detail' do
        get(:show, {:id => @service, :format => :json })
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service.to_json(:root => false, :only => [:name], :include => :current_additional_detail))
      end
      
      it 'has access to show HTML that redirects to additional_details' do
        get(:show, {:id => @service, :format => :html })
        expect(response).to redirect_to(additional_detail_service_additional_details_path(@service))
      end
    end
    
    describe 'is a core super_user and has access to' do
      before :each do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)
      end
          
      it 'show with the current additional_detail' do
        get(:show, {:id => @service, :format => :json })
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service.to_json(:root => false, :only => [:name], :include => :current_additional_detail))
      end
      
      it 'has access to show HTML that redirects to additional_details' do
        get(:show, {:id => @service, :format => :html })
        expect(response).to redirect_to(additional_detail_service_additional_details_path(@service))
      end
    end
    describe 'is a program super_user and has access to' do
      before :each do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)
      end
      
      it 'show with the current additional_detail' do
        get(:show, {:id => @service, :format => :json })
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service.to_json(:root => false, :only => [:name], :include => :current_additional_detail))
      end
      
      it 'has access to show HTML that redirects to additional_details' do
        get(:show, {:id => @service, :format => :html })
        expect(response).to redirect_to(additional_detail_service_additional_details_path(@service))
      end
    end
  end
end
