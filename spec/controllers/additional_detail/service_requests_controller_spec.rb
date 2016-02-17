# coding: utf-8
# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.
#
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

require 'rails_helper'

RSpec.describe AdditionalDetail::ServiceRequestsController do
  
  before :each do
    # associate a protocol to a service request and sub service request
    @protocol = Study.new
    @protocol.short_title = 'REDCap Project'
    @protocol.type = 'Study'
    @protocol.save(validate: false)
    
    # mock a service request      
    @service_request = ServiceRequest.new
    @service_request.protocol_id = @protocol.id
    @service_request.save(:validate => false)
    
    SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
    @sub_service_request = SubServiceRequest.new
    @sub_service_request.service_request_id = @service_request.id
    @sub_service_request.save(:validate => false)
    SubServiceRequest.set_callback(:save, :after, :update_org_tree)
        
    @core = Core.new
    @core.name = "REDCap"
    @core.save(validate: false)

    @service = Service.new
    @service.organization_id = @core.id
    @service.save(:validate => false)

    @line_item = LineItem.new
    @line_item.service_id = @service.id
    @line_item.sub_service_request_id = @sub_service_request.id
    @line_item.save(:validate => false)
  end

  describe 'user is not logged in and, thus, has no access to' do
    it 'a grid of line_item_additional_details' do
      get(:show, { :id=>@service_request.id , :format => :json })
      expect(response.status).to eq(401)
    end
    
    it 'a grid of line_item_additional_details' do
      get(:show, { :id=>@service_request.id , :format => :html })
      expect(response).to redirect_to("/identities/sign_in")
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
    
    it 'should see 404 for an invalid service_request.id' do
      get(:show, { :id => 1231231231 , :format => :json})
      expect(response.status).to eq(404)
      expect(response.body).to eq("")
      
      get(:show, { :id => 1231231231 , :format => :html})
      expect(response.status).to eq(404)
      expect(response).to render_template("additional_detail/service_requests/not_found")
      expect(assigns(:service_request)).to be_blank
    end
    
    describe 'has no affiliation with the project and, thus, has no access to' do
      it 'line_item_additional_details' do
        get(:show, { :id => @service_request.id , :format => :json})
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
        
        get(:show, { :id => @service_request.id , :format => :html})
        expect(response.status).to eq(401)
        expect(response).to render_template("additional_detail/shared/unauthorized")
        expect(assigns(:service_request)).to be_blank
      end
    end
    
    describe 'is the original service requester and, thus, has access to' do
      before :each do
        # associate user to the service request to give them authorization to view its additional details
        @service_request.service_requester_id = @identity.id
        @service_request.save(:validate => false)
      end
              
      it "view an empty set of line_item_additional_details" do
        get(:show, { :id => @service_request.id , :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq("{\"protocol_short_title\":\"REDCap Project\",\"get_or_create_line_item_additional_details\":[]}")
          
        get(:show, { :id => @service_request.id , :format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("show") 
        expect(assigns(:service_request)).to eq(@service_request) 
      end
  
      it "view a list of line_item_additional_details, after the controller creates a line_item_additional_detail record" do
        @ad = AdditionalDetail.new 
        @ad.enabled = true
        @ad.effective_date = Date.current.yesterday
        @ad.service_id = @service.id
        @ad.form_definition_json= '{"schema": {"required": ["t","date"] }}'
        @ad.save(:validate => false)
        # HTML requests should not create LineItemAdditionalDetails          
        expect{
          get(:show, { :id=>@service_request.id , :format => :html })
        }.to change{LineItemAdditionalDetail.count}.by(0)
        
        expect{
          get(:show, { :id=>@service_request.id , :format => :json })
        }.to change{LineItemAdditionalDetail.count}.by(1)
        @line_item_additional_detail = LineItemAdditionalDetail.where(:line_item_id => @line_item.id).last
        expect(@line_item_additional_detail.additional_detail_id).to eq(@ad.id)
        expect(@line_item_additional_detail.line_item_id).to eq(@line_item.id)
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service_request.to_json(:root=> false, :only => [], :methods => [:protocol_short_title], :include => { :get_or_create_line_item_additional_details => {:except => [:created_at, :updated_at], :methods => [:has_answered_all_required_questions?, :additional_detail_breadcrumb] }}))
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
      
      it "view an empty set of line_item_additional_details" do          
        get(:show, { :id => @service_request.id , :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq("{\"protocol_short_title\":\"REDCap Project\",\"get_or_create_line_item_additional_details\":[]}")
          
        get(:show, { :id => @service_request.id , :format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("show")
        expect(assigns(:service_request)).to eq(@service_request) 
      end
  
      it "view a list of line_item_additional_details, after the controller creates a line_item_additional_detail record" do
        @ad = AdditionalDetail.new 
        @ad.enabled = true
        @ad.effective_date = Date.current.yesterday
        @ad.service_id = @service.id
        @ad.form_definition_json= '{"schema": {"required": ["t","date"] }}'
        @ad.save(:validate => false)
        
        # HTML requests should not create LineItemAdditionalDetails          
        expect{
          get(:show, { :id=>@service_request.id , :format => :html })
        }.to change{LineItemAdditionalDetail.count}.by(0)      
          
        expect{
          get(:show, { :id=>@service_request.id , :format => :json })
        }.to change{LineItemAdditionalDetail.count}.by(1)
        @line_item_additional_detail = LineItemAdditionalDetail.where(:line_item_id => @line_item.id).last
        expect(@line_item_additional_detail.additional_detail_id).to eq(@ad.id)
        expect(@line_item_additional_detail.line_item_id).to eq(@line_item.id)
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service_request.to_json(:root=> false, :only => [], :methods => [:protocol_short_title], :include => { :get_or_create_line_item_additional_details => {:except => [:created_at, :updated_at], :methods => [:has_answered_all_required_questions?, :additional_detail_breadcrumb] }}))
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
      
      it "view an empty set of line_item_additional_details" do          
        get(:show, { :id => @service_request.id , :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq("{\"protocol_short_title\":\"REDCap Project\",\"get_or_create_line_item_additional_details\":[]}")
          
        get(:show, { :id => @service_request.id , :format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("show")
        expect(assigns(:service_request)).to eq(@service_request) 
      end
    
      it "view a list of line_item_additional_details, after the controller creates a line_item_additional_detail record" do
        @ad = AdditionalDetail.new 
        @ad.enabled = true
        @ad.effective_date = Date.current.yesterday
        @ad.service_id = @service.id
        @ad.form_definition_json= '{"schema": {"required": ["t","date"] }}'
        @ad.save(:validate => false)

        # HTML requests should not create LineItemAdditionalDetails          
        expect{
          get(:show, { :id=>@service_request.id , :format => :html })
        }.to change{LineItemAdditionalDetail.count}.by(0)
                
        expect{
          get(:show, { :id=>@service_request.id , :format => :json })
        }.to change{LineItemAdditionalDetail.count}.by(1)
        @line_item_additional_detail = LineItemAdditionalDetail.where(:line_item_id => @line_item.id).last
        expect(@line_item_additional_detail.additional_detail_id).to eq(@ad.id)
        expect(@line_item_additional_detail.line_item_id).to eq(@line_item.id)
        expect(response.status).to eq(200)
        expect(response.body).to eq(@service_request.to_json(:root=> false, :only => [], :methods => [:protocol_short_title], :include => { :get_or_create_line_item_additional_details => {:except => [:created_at, :updated_at], :methods => [:has_answered_all_required_questions?, :additional_detail_breadcrumb] }}))
      end
    end 
    
    describe 'is a project team member with "view" rights and, thus, has NO access to' do
      before :each do
        @project_role = ProjectRole.new
        @project_role.identity_id = @identity.id
        @project_role.protocol_id = @protocol.id
        @project_role.project_rights = 'view'
        @project_role.save(validate: false)
      end
      
      it "view an empty set of line_item_additional_details" do          
        get(:show, { :id => @service_request.id , :format => :json})
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
        
        get(:show, { :id => @service_request.id , :format => :html})
        expect(response.status).to eq(401)
        expect(response).to render_template("additional_detail/shared/unauthorized")
        expect(assigns(:service_request)).to be_blank
      end
    end  
    
    describe 'is a project team member with "none" rights and, thus, has NO access to' do
      before :each do
        @project_role = ProjectRole.new
        @project_role.identity_id = @identity.id
        @project_role.protocol_id = @protocol.id
        @project_role.project_rights = 'none'
        @project_role.save(validate: false)
      end
      
      it "view an empty set of line_item_additional_details" do          
        get(:show, { :id => @service_request.id , :format => :json})
        expect(response.status).to eq(401)
        expect(response.body).to eq("")
        
        get(:show, { :id => @service_request.id , :format => :html})
        expect(response.status).to eq(401)
        expect(response).to render_template("additional_detail/shared/unauthorized")
        expect(assigns(:service_request)).to be_blank
      end
    end    
    
  describe 'is a service provider and, thus, has NO access to' do
    before :each do
      @service_provider = ServiceProvider.new
      @service_provider.identity_id = @identity.id
      @service_provider.organization_id = @core.id
      @service_provider.save(validate: false)
    end
    
    it "view an empty set of line_item_additional_details" do          
      get(:show, { :id => @service_request.id , :format => :json})
      expect(response.status).to eq(401)
      expect(response.body).to eq("")
      
      get(:show, { :id => @service_request.id , :format => :html})
      expect(response.status).to eq(401)
      expect(response).to render_template("additional_detail/shared/unauthorized")
      expect(assigns(:service_request)).to be_blank
    end
  end 
  
  describe 'is a catalog manager and, thus, has NO access to' do
    before :each do
      @catalog_manager = CatalogManager.new
      @catalog_manager.identity_id = @identity.id
      @catalog_manager.organization_id = @core.id
      @catalog_manager.save(validate: false)
    end
    
    it "view an empty set of line_item_additional_details" do          
      get(:show, { :id => @service_request.id , :format => :json})
      expect(response.status).to eq(401)
      expect(response.body).to eq("")
      
      get(:show, { :id => @service_request.id , :format => :html})
      expect(response.status).to eq(401)
      expect(response).to render_template("additional_detail/shared/unauthorized")
      expect(assigns(:service_request)).to be_blank
    end
  end 
  
  describe 'is a super user and, thus, has NO access to' do
    before :each do
      @super_user = SuperUser.new
      @super_user.identity_id = @identity.id
      @super_user.organization_id = @core.id
      @super_user.save(validate: false)
    end
    
    it "view an empty set of line_item_additional_details" do          
      get(:show, { :id => @service_request.id , :format => :json})
      expect(response.status).to eq(401)
      expect(response.body).to eq("")
      
      get(:show, { :id => @service_request.id , :format => :html})
      expect(response.status).to eq(401)
      expect(response).to render_template("additional_detail/shared/unauthorized")
      expect(assigns(:service_request)).to be_blank
    end
  end 
  end
end
