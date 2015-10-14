require 'rails_helper'

RSpec.describe AdditionalDetail::LineItemAdditionalDetailsController do
  
  before :each do
    # create a catalog hierarchy
    @institution = Institution.new
    @institution.type = "Institution"
    @institution.save(validate: false)

    @provider = Provider.new
    @provider.type = "Provider"
    @provider.parent_id = @institution.id
    @provider.save(validate: false)

    @program = Program.new
    @program.type = "Program"
    @program.parent_id = @provider.id
    @program.save(validate: false)

    @core = Core.new
    @core.type = "Core"
    @core.parent_id = @program.id
    @core.save(validate: false)
    
    # associate a protocol to a service request and sub service request
    @protocol = Study.new
    @protocol.type = 'Study'
    @protocol.save(validate: false)
    
    @service_request = ServiceRequest.new
    @service_request.protocol_id = @protocol.id
    @service_request.save(:validate => false)
    
    @sub_service_request = SubServiceRequest.new
    @sub_service_request.service_request_id = @service_request.id
    SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
    @sub_service_request.save(validate: false)
    SubServiceRequest.set_callback(:save, :after, :update_org_tree)
    
    # add a line item to the service request  
    @line_item = LineItem.new
    @line_item.service_request_id = @service_request.id
    @line_item.sub_service_request_id = @sub_service_request.id
    @line_item.save(:validate => false)
    
    # add a line item additional detail to the line item
    @line_item_additional_detail = LineItemAdditionalDetail.new
    @line_item_additional_detail.line_item_id = @line_item.id
    @line_item_additional_detail.save(:validate => false)
  end
    
  describe 'user is not logged in and, thus, has no access to' do
    it 'view a line_item_additional_detail' do
      get(:show, {:id => @line_item_additional_detail})
      expect(response).to redirect_to("/identities/sign_in")
    end
    
    it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
      put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
      expect(response).to redirect_to("/identities/sign_in")
      expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq(nil)
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

    it 'should see 404s for an invalid line_item_additional_detail.id' do
      get(:show, {:id => 1231231231})
      expect(response.status).to eq(404)
      expect(response.body).to eq("")
      
      put(:update, {:id => 1231231231, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
      expect(response.status).to eq(404)
      expect(response.body).to eq("")
      expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq(nil)
    end
    
    describe 'has no affiliation with the project and, thus, has no access to' do
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq(nil)
      end
    end
    
    describe 'is a project team member with "approve" rights and, thus, has access to' do
      before :each do
        @project_role = ProjectRole.new
        @project_role.identity_id = @identity.id
        @project_role.protocol_id = @protocol.id
        @project_role.project_rights = 'approve'
        @project_role.save(validate: false)
      end
      
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json(:root => false))
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(204)
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq('{ "real" : "JSON" }')
      end
      
      it 'view failed validation messages after an attempt to update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => ""} }) 
        expect(response.status).to eq(422)
        expect(response.body).to eq("{\"form_data_json\":[\"can't be blank\"]}")
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq(nil)
      end
    end
    
    describe 'is a project team member with "request" rights and, thus, has access to' do
      before :each do
        @project_role = ProjectRole.new
        @project_role.identity_id = @identity.id
        @project_role.protocol_id = @protocol.id
        @project_role.project_rights = 'request'
        @project_role.save(validate: false)
      end
      
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json(:root => false))
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(204)
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq('{ "real" : "JSON" }')
      end
     
    end 
    
    describe 'is a project team member with "view" rights and, thus, ' do
      before :each do
        @project_role = ProjectRole.new
        @project_role.identity_id = @identity.id
        @project_role.protocol_id = @protocol.id
        @project_role.project_rights = 'view'
        @project_role.save(validate: false)
      end
      
      it 'has access to view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json(:root => false))
      end
      
      it 'does NOT have access to update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq(nil)
      end
    end   
    
    describe 'is a project team member with "none" rights and, thus, ' do
      before :each do
        @project_role = ProjectRole.new
        @project_role.identity_id = @identity.id
        @project_role.protocol_id = @protocol.id
        @project_role.project_rights = 'none'
        @project_role.save(validate: false)
      end
      
      it 'does NOT have access to view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
      end
      
      it 'does NOT have access to update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq(nil)
      end
    end        
          
    describe 'is a service provider for a core service and, thus, has access to' do
      before :each do
        @core_service = Service.new
        @core_service.organization_id = @core.id
        @core_service.save(validate: false)
                
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)
        
        # update the line item
        @line_item.service_id = @core_service.id
        @line_item.save(:validate => false)
        
        # update the organization
        @sub_service_request.organization_id = @core.id
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        @sub_service_request.save(validate: false)
        SubServiceRequest.set_callback(:save, :after, :update_org_tree)
      end
      
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json(:root => false))
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(204)
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq('{ "real" : "JSON" }')
      end
    end
    
    describe 'is a service provider for a program service and, thus, has access to' do
      before :each do
        @program_service = Service.new
        @program_service.organization_id = @program.id
        @program_service.save(validate: false)
                
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)
        
        # update the line item
        @line_item.service_id = @program_service.id
        @line_item.save(:validate => false)
        
        # update the organization
        @sub_service_request.organization_id = @program.id
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        @sub_service_request.save(validate: false)
        SubServiceRequest.set_callback(:save, :after, :update_org_tree)
      end
      
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json(:root => false))
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(204)
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq('{ "real" : "JSON" }')
      end
    end    
    
    describe 'is a super user for a core service and, thus, has access to' do
      before :each do
        @core_service = Service.new
        @core_service.organization_id = @core.id
        @core_service.save(validate: false)
        
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)
        
        # update the organization
        @sub_service_request.organization_id = @core.id
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        @sub_service_request.save(validate: false)
        SubServiceRequest.set_callback(:save, :after, :update_org_tree)
      end
      
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json(:root => false))
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(204)
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq('{ "real" : "JSON" }')
      end
    end     

    describe 'is a super user for a program service and, thus, has access to' do
      before :each do
        @program_service = Service.new
        @program_service.organization_id = @program.id
        @program_service.save(validate: false)
        
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)
        
        # update the organization
        @sub_service_request.organization_id = @program.id
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        @sub_service_request.save(validate: false)
        SubServiceRequest.set_callback(:save, :after, :update_org_tree)
      end
      
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json(:root => false))
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(204)
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq('{ "real" : "JSON" }')
      end
    end   

    describe 'is a catalog manager for a core service and, thus, has NO access to' do
      before :each do
        @core_service = Service.new
        @core_service.organization_id = @core.id
        @core_service.save(validate: false)
        
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @core.id
        @catalog_manager.save(validate: false)
        
        # update the organization
        @sub_service_request.organization_id = @core.id
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        @sub_service_request.save(validate: false)
        SubServiceRequest.set_callback(:save, :after, :update_org_tree)
      end
      
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq(nil)
      end
    end     

    describe 'is a catalog manager for a program service and, thus, has NO access to' do
      before :each do
        @program_service = Service.new
        @program_service.organization_id = @program.id
        @program_service.save(validate: false)
        
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
        @catalog_manager.organization_id = @program.id
        @catalog_manager.save(validate: false)
        
        # update the organization
        @sub_service_request.organization_id = @program.id
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        @sub_service_request.save(validate: false)
        SubServiceRequest.set_callback(:save, :after, :update_org_tree)
      end
      
      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail})
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
      end
      
      it 'update a line_item_additional_detail (i.e., submit/update answers to questions)' do
        put(:update, {:id => @line_item_additional_detail, :line_item_additional_detail => { :form_data_json => '{ "real" : "JSON" }'} }) 
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
        expect(LineItemAdditionalDetail.find(@line_item_additional_detail).form_data_json).to eq(nil)
      end
    end                  
  end
  
end
