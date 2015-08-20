require 'spec_helper'

describe AdditionalDetail::AdditionalDetailsController do
  
  before :each do
    @institution = Institution.new
    @institution.type = "Institution"
    @institution.abbreviation = "TECHU"
    @institution.save(validate: false)
    
    @provider = Provider.new
    @provider.type = "Provider"
    @provider.abbreviation = "ICTS"
    @provider.parent_id = @institution.id
    @provider.save(validate: false)
    
    @program = Program.new
    @program.type = "Program"
    @program.name = "BMI"
    @program.parent_id = @provider.id
    @program.save(validate: false)
    
    @core = Core.new
    @core.type = "Core"
    @core.name = "REDCap"
    @core.parent_id = @program.id
    @core.save(validate: false)
    
    @core_service = Service.new
    @core_service.organization_id = @core.id
    @core_service.save(validate: false)
    
    @program_service = Service.new
    @program_service.organization_id = @program.id
    @program_service.save(validate: false)
  end
  
  describe 'user is not logged in and, thus, has no access to' do
    it 'a core service index' do
      get(:index, {:service_id => @core_service, :format => :html}) 
      response.should redirect_to("/identities/sign_in")
    end
    
    it 'a program service index' do
      get(:index, {:service_id => @program_service, :format => :html}) 
      response.should redirect_to("/identities/sign_in")
    end
    
    it 'a core service new additional detail page' do
      get(:new, {:service_id => @core_service, :format => :html}) 
      response.should redirect_to("/identities/sign_in")
    end
    
    it 'a program service new additional detail page' do
      get(:new, {:service_id => @program_service, :format => :html}) 
      response.should redirect_to("/identities/sign_in")
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
    
    describe 'is not a catalog_manager or super_user and, thus, has no access to' do
      
      it 'a core service index' do
        get(:index, {:service_id => @core_service, :format => :html}) 
        response.should render_template("unauthorized")
        expect(response.status).to eq(401)
        assigns(:service).should be_blank
      end
      
      it 'a core service index even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)  
                  
        get(:index, {:service_id => @core_service, :format => :html}) 
        response.should render_template("unauthorized")
        expect(response.status).to eq(401)
        assigns(:service).should be_blank
      end
      
      it 'a program service index' do
        get(:index, {:service_id => @program_service, :format => :html}) 
        response.should render_template("unauthorized")
        expect(response.status).to eq(401)
        assigns(:service).should be_blank
      end
      
      it 'a program service index even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)  
                
        get(:index, {:service_id => @program_service, :format => :html}) 
        response.should render_template("unauthorized")
        expect(response.status).to eq(401)
        assigns(:service).should be_blank
      end
      
      it 'a new core service additional detail page' do
        get(:new, {:service_id => @core_service, :format => :html}) 
        response.should render_template("unauthorized")
        expect(response.status).to eq(401)
        assigns(:service).should be_blank
        assigns(:additional_detail).should be_blank
      end
      
      it 'a new core service additional detail page even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)  
                
        get(:new, {:service_id => @core_service, :format => :html}) 
        response.should render_template("unauthorized")
        expect(response.status).to eq(401)
        assigns(:service).should be_blank
        assigns(:additional_detail).should be_blank
      end
      
      it 'a new program service additional detail page' do
        get(:new, {:service_id => @program_service, :format => :html}) 
        response.should render_template("unauthorized")
        expect(response.status).to eq(401)
        assigns(:service).should be_blank
        assigns(:additional_detail).should be_blank
      end
      
      it 'a new program service additional detail page even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)  
                
        get(:new, {:service_id => @program_service, :format => :html}) 
        response.should render_template("unauthorized")
        expect(response.status).to eq(401)
        assigns(:service).should be_blank
        assigns(:additional_detail).should be_blank
      end
    end
  
    describe 'is a catalog_manager and has access to' do
      it 'a core service index' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @core.id
        @catalog_manager.save(validate: false)  
                
        get(:index, {:service_id => @core_service, :format => :html}) 
        response.should render_template("index")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
      end
      
      it 'a core service index because user is a catalog_manager for its program' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false)  
                
        get(:index, {:service_id => @core_service, :format => :html}) 
        response.should render_template("index")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
      end
      
      it 'a program service index' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false) 
        
        get(:index, {:service_id => @program_service, :format => :html}) 
        response.should render_template("index")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
      end
      
      it 'a core service new additional detail page' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @core.id
        @catalog_manager.save(validate: false) 
        
        get(:new, {:service_id => @core_service, :format => :html}) 
        response.should render_template("new")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
        assigns(:additional_detail).should_not be_blank
      end
      
      it 'a core service new additional detail page because user is a catalog_manager for its program' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false) 
        
        get(:new, {:service_id => @core_service, :format => :html}) 
        response.should render_template("new")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
        assigns(:additional_detail).should_not be_blank
      end
      
      it 'a program service new additional detail page' do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false) 
        
        get(:new, {:service_id => @program_service, :format => :html}) 
        response.should render_template("new")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
        assigns(:additional_detail).should_not be_blank
      end
  
    end
    
    describe 'is a super_user and has access to' do
      it 'a core service index' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)  
        
        get(:index, {:service_id => @core_service, :format => :html}) 
        response.should render_template("index")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
      end
      
      it 'a program service index' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)  
        
        get(:index, {:service_id => @program_service, :format => :html}) 
        response.should render_template("index")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
      end
      
      it 'a core service new additional detail page' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)  
        
        get(:new, {:service_id => @core_service, :format => :html}) 
        response.should render_template("new")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
        assigns(:additional_detail).should_not be_blank
      end
      
      it 'a program service new additional detail page' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)  
        
        get(:new, {:service_id => @program_service, :format => :html}) 
        response.should render_template("new")
        expect(response.status).to eq(200)
        assigns(:service).should_not be_blank
        assigns(:additional_detail).should_not be_blank
      end
    end
  end
end
