# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'spec_helper'

##########################
# Test Protocol Security #
##########################
describe Portal::AssociatedUsersController do
  stub_portal_controller
  
  before :each do
    @identity = Identity.new
    @identity.approved = true
    @identity.save(validate: false)
    
    session[:identity_id] = @identity.id
      
    @protocol = Study.new
    @protocol.type = 'Study'
    @protocol.save(validate: false)
    
    @associated_user = Identity.new
    @associated_user.approved = true
    @associated_user.save(validate: false)
    
    @associated_user_project_role = ProjectRole.new
    @associated_user_project_role.identity_id = @associated_user.id
    @associated_user_project_role.protocol_id = @protocol.id
    @associated_user_project_role.project_rights = 'approve'
    @associated_user_project_role.save(validate: false)
  end
  
  describe 'identity has NO related roles and, thus, no access to' do
    it 'show' do
      get(:show, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user.id }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
        
    it 'edit' do
      get(:edit, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'new' do
      get(:new, {:format => :js, :protocol_id => @protocol.id, :user_id => @associated_user.id }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'create' do
      @user_to_be_associated = Identity.new
      @user_to_be_associated.approved = true
      @user_to_be_associated.save(validate: false)
      
      post(:create, {:format => :js, :protocol_id => @protocol.id, :project_role => { :protocol_id => @protocol.id, :identity_id => @user_to_be_associated.id, :project_rights => 'approve' } }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'update' do            
      post(:update, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id, :project_role => {} }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
  end  
  
  describe 'checks project roles and, if identity has "approve" rights, authorize' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
      @project_role.project_rights = 'approve'
      @project_role.save(validate: false)
    end
  
    it 'show' do
      get(:show, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user.id }) 
      assigns(:protocol).should eq @protocol
      response.body.should be_blank
    end
        
    it 'edit' do
      get(:edit, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id }) 
      assigns(:protocol).should eq @protocol
      response.should render_template("edit")
    end
    
    it 'new' do
      get(:new, {:format => :js, :protocol_id => @protocol.id, :user_id => @associated_user.id }) 
      assigns(:protocol).should eq @protocol
      response.should render_template("new")
    end
    
    it 'create' do
      @user_to_be_associated = Identity.new
      @user_to_be_associated.approved = true
      @user_to_be_associated.save(validate: false)
      
      post(:create, {:format => :js, :protocol_id => @protocol.id, :project_role => { :protocol_id => @protocol.id, :identity_id => @user_to_be_associated.id, :project_rights => 'approve' } }) 
      assigns(:protocol).should eq @protocol
      response.body.should be_blank
    end
    
    it 'update' do            
      post(:update, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id, :project_role => {} }) 
      assigns(:protocol).should eq @protocol
      response.body.should be_blank
    end
  end
  
  describe 'checks project roles and, if identity has "request" rights, authorize' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
      @project_role.project_rights = 'request'
      @project_role.save(validate: false)
    end
  
    it 'show' do
      get(:show, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user.id }) 
      assigns(:protocol).should eq @protocol
      response.body.should be_blank
    end
        
    it 'edit' do
      get(:edit, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id }) 
      assigns(:protocol).should eq @protocol
      response.should render_template("edit")
    end
    
    it 'new' do
      get(:new, {:format => :js, :protocol_id => @protocol.id, :user_id => @associated_user.id }) 
      assigns(:protocol).should eq @protocol
      response.should render_template("new")
    end
    
    it 'create' do
      @user_to_be_associated = Identity.new
      @user_to_be_associated.approved = true
      @user_to_be_associated.save(validate: false)
      
      post(:create, {:format => :js, :protocol_id => @protocol.id, :project_role => { :protocol_id => @protocol.id, :identity_id => @user_to_be_associated.id, :project_rights => 'approve' } }) 
      assigns(:protocol).should eq @protocol
      response.body.should be_blank
    end
    
    it 'update' do            
      post(:update, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id, :project_role => {} }) 
      assigns(:protocol).should eq @protocol
      response.body.should be_blank
    end
  end  
  
  describe 'checks project roles and, if identity has "view" rights,' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
      @project_role.project_rights = 'view'
      @project_role.save(validate: false)
    end
  
    it 'authorize show' do
      get(:show, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user.id }) 
      assigns(:protocol).should eq @protocol
      response.body.should be_blank
    end
        
    it 'do NOT authorize edit' do
      get(:edit, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'do NOT authorize new' do
      get(:new, {:format => :js, :protocol_id => @protocol.id, :user_id => @associated_user.id }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'do NOT authorize create' do
      @user_to_be_associated = Identity.new
      @user_to_be_associated.approved = true
      @user_to_be_associated.save(validate: false)
      
      post(:create, {:format => :js, :protocol_id => @protocol.id, :project_role => { :protocol_id => @protocol.id, :identity_id => @user_to_be_associated.id, :project_rights => 'approve' } }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'do NOT authorize update' do            
      post(:update, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id, :project_role => {} }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
  end      
  
  describe 'checks project roles and, if identity has "none" rights, do NOT authorize' do
    before :each do
      @project_role = ProjectRole.new
      @project_role.identity_id = @identity.id
      @project_role.protocol_id = @protocol.id
      @project_role.project_rights = 'none'
      @project_role.save(validate: false)
    end
  
    it 'show' do
      get(:show, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user.id }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
        
    it 'edit' do
      get(:edit, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'new' do
      get(:new, {:format => :js, :protocol_id => @protocol.id, :user_id => @associated_user.id }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'create' do
      @user_to_be_associated = Identity.new
      @user_to_be_associated.approved = true
      @user_to_be_associated.save(validate: false)
      
      post(:create, {:format => :js, :protocol_id => @protocol.id, :project_role => { :protocol_id => @protocol.id, :identity_id => @user_to_be_associated.id, :project_rights => 'approve' } }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
    
    it 'update' do            
      post(:update, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id, :project_role => {} }) 
      assigns(:protocol).should eq nil
      response.should render_template(:partial => "_authorization_error")
    end
  end    
  
  describe 'checks service providers, clinical providers, and super users for a ' do
    before :each do
      # create service request and associate it to a protocol via an organization (i.e., core)
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
      
      @service_request = ServiceRequest.new
      @service_request.protocol_id = @protocol.id
      @service_request.save(validate: false)
    end
    
    describe 'sub service request connected to a core and users within' do
      before :each do
        @sub_service_request = SubServiceRequest.new
        @sub_service_request.organization_id = @core.id
        @sub_service_request.service_request_id = @service_request.id  
        @sub_service_request.save(validate: false)    
      end
  
      describe 'cores' do 
        it 'should authorize view and edit if identity is a service provider for a sub service request that is servicing the protocol' do
          @service_provider = ServiceProvider.new
          @service_provider.identity_id = @identity.id
          @service_provider.organization_id = @core.id
          @service_provider.save(validate: false)  
          
          get(:show, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user.id }) 
          assigns(:protocol).should eq @protocol
          response.body.should be_blank

          get(:edit, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id }) 
          assigns(:protocol).should eq @protocol
          response.should render_template("edit")

          get(:new, {:format => :js, :protocol_id => @protocol.id, :user_id => @associated_user.id }) 
          assigns(:protocol).should eq @protocol
          response.should render_template("new")

          post(:update, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id, :project_role => {} }) 
          assigns(:protocol).should eq @protocol
          response.body.should be_blank
            
          @user_to_be_associated = Identity.new
          @user_to_be_associated.approved = true
          @user_to_be_associated.save(validate: false)
          
          post(:create, {:format => :js, :protocol_id => @protocol.id, :project_role => { :protocol_id => @protocol.id, :identity_id => @user_to_be_associated.id, :project_rights => 'approve' } }) 
          assigns(:protocol).should eq @protocol
          response.body.should be_blank         
        end
        
        it 'should NOT authorize view and edit if identity is a clinical provider for a sub service request that is servicing the protocol' do
          @clinical_provider = ClinicalProvider.new
          @clinical_provider.identity_id = @identity.id
          @clinical_provider.organization_id = @core.id
          @clinical_provider.save(validate: false)  
          
          get(:show, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user.id }) 
          assigns(:protocol).should eq nil
          response.should render_template(:partial => "_authorization_error")

          get(:edit, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id }) 
          assigns(:protocol).should eq nil
          response.should render_template(:partial => "_authorization_error")

          get(:new, {:format => :js, :protocol_id => @protocol.id, :user_id => @associated_user.id }) 
          assigns(:protocol).should eq nil
          response.should render_template(:partial => "_authorization_error")
           
          post(:update, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id, :project_role => {} }) 
          assigns(:protocol).should eq nil
          response.should render_template(:partial => "_authorization_error")
          
          @user_to_be_associated = Identity.new
          @user_to_be_associated.approved = true
          @user_to_be_associated.save(validate: false)
          
          post(:create, {:format => :js, :protocol_id => @protocol.id, :project_role => { :protocol_id => @protocol.id, :identity_id => @user_to_be_associated.id, :project_rights => 'approve' } }) 
          assigns(:protocol).should eq nil
          response.should render_template(:partial => "_authorization_error")
        end
        
        it 'should authorize view and edit if identity is a super user for a sub service request that is servicing the protocol' do
          @super_user = SuperUser.new
          @super_user.identity_id = @identity.id
          @super_user.organization_id = @core.id
          @super_user.save(validate: false)  
          
          get(:show, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user.id }) 
          assigns(:protocol).should eq @protocol
          response.body.should be_blank

          get(:edit, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id }) 
          assigns(:protocol).should eq @protocol
          response.should render_template("edit")

          get(:new, {:format => :js, :protocol_id => @protocol.id, :user_id => @associated_user.id }) 
          assigns(:protocol).should eq @protocol
          response.should render_template("new")

          post(:update, {:format => :js, :protocol_id => @protocol.id, :id => @associated_user_project_role.id, :identity_id => @associated_user.id, :project_role => {} }) 
          assigns(:protocol).should eq @protocol
          response.body.should be_blank
            
          @user_to_be_associated = Identity.new
          @user_to_be_associated.approved = true
          @user_to_be_associated.save(validate: false)
          
          post(:create, {:format => :js, :protocol_id => @protocol.id, :project_role => { :protocol_id => @protocol.id, :identity_id => @user_to_be_associated.id, :project_rights => 'approve' } }) 
          assigns(:protocol).should eq @protocol
          response.body.should be_blank      
        end
      end
    end
  end
end
