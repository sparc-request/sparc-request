require 'rails_helper'

RSpec.describe AdditionalDetail::AdditionalDetailsController do

  before :each do
    @program = Program.new
    @program.type = "Program"
    @program.name = "BMI"
    @program.save(validate: false)

    @core = Core.new
    @core.type = "Core"
    @core.name = "REDCap"
    @core.parent_id = @program.id
    @core.save(validate: false)

    @core_service = Service.new
    @core_service.organization_id = @core.id
    @core_service.save(validate: false)

    @additional_detail = AdditionalDetail.new
    @additional_detail.name = "Test"
    @additional_detail.service_id = @core_service.id
    @additional_detail.form_definition_json= '{"schema": {"required": ["t","date"] }}'
    @additional_detail.effective_date = Date.today
    @additional_detail.enabled = "true"
    @additional_detail.save
    
    @program_service = Service.new
    @program_service.organization_id = @program.id
    @program_service.save(validate: false)
  end

  describe 'user is not logged in and, thus, has no access to' do
    it 'a core service index' do
      get(:index, {:service_id => @core_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
      
      get(:index, {:service_id => @core_service, :format => :json})
      expect(response.status).to eq(401)
    end

    it 'a core service new additional detail page' do
      get(:new, {:service_id => @core_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end
    
    it 'duplicate an additional detail' do
      get(:duplicate,{:service_id => @core_service, :id => @additional_detail, :format =>:html})
      expect(response).to redirect_to("/identities/sign_in")
    end
    
    it "show an additional detail" do
      get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
      expect(response.status).to eq(401)
    end
    
    it "update_enabled" do
      put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "false"} })
      expect(response.status).to eq(302)
    end
      
    it 'a program service index' do
      get(:index, {:service_id => @program_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
      
      get(:index, {:service_id => @program_service, :format => :json})
      expect(response.status).to eq(401)
    end

    it 'a program service new additional detail page' do
      get(:new, {:service_id => @program_service, :format => :html})
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

    describe 'is not a service_provider, catalog_manager, or super_user and, thus, has no access to' do
      it 'a core service index' do
        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        #expect(assigns(:service)).to be_blank
      end
      
      it 'a new core service additional detail page' do
        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end
      
      it 'duplicate an additional detail' do
        get(:duplicate,{:service_id => @core_service, :id => @additional_detail, :format =>:html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end
      
      it "show an additional detail" do
        get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
        expect(response.status).to eq(401)
      end
      
      it "update_enabled" do
        put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "false"} })
        expect(response.status).to eq(401)
      end
      
      it 'a program service index' do
        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
      end

      it 'a new program service additional detail page' do
        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end
    end

    describe 'is a core service provider and' do
      before :each do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)
      end
      
      it 'should have access to the index page' do 
        get(:index, {:service_id => @core_service, :format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("index")
        expect(assigns(:service)).to_not be_blank
          
        get(:index, {:service_id => @core_service, :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq("["+@additional_detail.to_json(:root => false, :include => :line_item_additional_details)+"]")
      end
     
      it 'should NOT be able to duplicate an additional detail' do
        get(:duplicate,{:service_id => @core_service, :id => @additional_detail, :format =>:html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end
      
      it "should NOT be able to show an additional detail" do
        get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
        expect(response.status).to eq(401)
      end
      
      it "should NOT be able to update_enabled" do
        put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "false"} })
        expect(response.status).to eq(401)
      end
    end
    
    describe 'is a program service provider and' do
      before :each do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)
      end
      
      it 'should have access to the index page' do
        get(:index, {:service_id => @program_service, :format => :html})
        expect(response.status).to eq(200)
        expect(response).to render_template("index")
        expect(assigns(:service)).to_not be_blank
          
        get(:index, {:service_id => @program_service, :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq("[]") # zero additional_details
      end
      
      it 'should NOT be able to duplicate an additional detail' do
        get(:duplicate,{:service_id => @core_service, :id => @additional_detail, :format =>:html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end
      
      it "should NOT be able to show an additional detail" do
        get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
        expect(response.status).to eq(401)
      end
      
      it "should NOT be able to update_enabled" do
        put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "false"} })
        expect(response.status).to eq(401)
      end
    end
    
    describe 'is a catalog_manager' do
      before :each do
        @catalog_manager = CatalogManager.new
        @catalog_manager.identity_id = @identity.id
      end

      describe 'for a core and and has access to' do
        before :each do
          @catalog_manager.organization_id = @core.id
          @catalog_manager.save(validate: false)
        end

        it 'a core service index' do
          get(:index, {:service_id => @core_service, :format => :html})
          expect(response).to render_template("index")
          expect(response.status).to eq(200)
          expect(assigns(:service)).to_not be_blank
            
          get(:index, {:service_id => @core_service, :format => :json})
          expect(response.status).to eq(200)
          expect(response.body).to eq("["+@additional_detail.to_json(:root => false, :include => :line_item_additional_details)+"]")
        end

        it 'a core service new additional detail page' do
          get(:new, {:service_id => @core_service, :format => :html})
          expect(response).to render_template("new")
          expect(response.status).to eq(200)
          expect(assigns(:service)).to_not be_blank
          expect(assigns(:additional_detail)).to_not be_blank
        end

        it "duplicate an additional detail" do
          get(:duplicate,{:service_id => @core_service, :id => @additional_detail, :format =>:html})
          expect(response.status).to eq(200)
          expect(response).to render_template(:action => 'new')
          expect(assigns(:additional_detail).name).to eq(@additional_detail.name)
          expect(assigns(:additional_detail).form_definition_json).to eq(@additional_detail.form_definition_json)
          # effective date should be nil so that the admin user has decide when to make it effective
          expect(assigns(:additional_detail).effective_date).to eq(nil)
          expect(assigns(:additional_detail).enabled).to eq(@additional_detail.enabled)
        end

        it "update an additional detail" do
          put(:update, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :name => "Test2"} })
          expect(response).to redirect_to(additional_detail_service_additional_details_path(@core_service))
          expect(AdditionalDetail.find(@additional_detail.id).name).to eq("Test2")
        end
        
        it "update_enabled should toggle enabled from true to false back to true and NOT change the name" do
          put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "false", :name => "Test2"} })
          expect(response.status).to eq(204)
          expect(response.body).to eq(" ")
          expect(AdditionalDetail.find(@additional_detail.id).enabled).to eq(false)
          expect(AdditionalDetail.find(@additional_detail.id).name).to eq("Test")
          
          put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "true", :name => "Test2"} })
          expect(response.status).to eq(204)
          expect(response.body).to eq(" ")
          expect(AdditionalDetail.find(@additional_detail.id).enabled).to eq(true)
          expect(AdditionalDetail.find(@additional_detail.id).name).to eq("Test")
        end

        it "delete an additional detail" do
          expect{
            delete(:destroy, {:service_id => @core_service, :id => @additional_detail, :format => :json})
            expect(response.status).to eq(204)
          }.to change(AdditionalDetail, :count).by(-1)
        end

        it "view an additional detail edit page" do
          get(:edit,{:service_id => @core_service, :id => @additional_detail, :format =>:html})
          expect(response.status).to eq(200)
          expect(response).to render_template(:action => 'new')
        end

        describe '(with a line item additional detail present)' do
          before :each do
            @line_item_additional_detail = LineItemAdditionalDetail.new
            @line_item_additional_detail.additional_detail_id = @additional_detail.id
            @line_item_additional_detail.save(validate: false)
          end

          it "cannot delete an additional detail" do
            expect{
              delete(:destroy, {:service_id => @core_service, :id => @additional_detail, :format => :json})
              expect(response.status).to eq(422)
            }.to change(AdditionalDetail, :count).by(0)
          end

          it "cannot update an additional detail" do
            put(:update, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :name => "Test2"} })
            expect(response.status).to eq(200)
            expect(AdditionalDetail.find(@additional_detail.id).name).to eq("Test")
          end
          
          it "update_enabled should still be able to toggle enabled from true to false back to true and NOT change the name" do
            put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "false", :name => "Test2"} })
            expect(response.status).to eq(204)
            expect(response.body).to eq(" ")
            expect(AdditionalDetail.find(@additional_detail.id).enabled).to eq(false)
            expect(AdditionalDetail.find(@additional_detail.id).name).to eq("Test")
            
            put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "true", :name => "Test2"} })
            expect(response.status).to eq(204)
            expect(response.body).to eq(" ")
            expect(AdditionalDetail.find(@additional_detail.id).enabled).to eq(true)
            expect(AdditionalDetail.find(@additional_detail.id).name).to eq("Test")
          end
        end
        

        it 'create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Date.tomorrow, :enabled => "true"}
            })
            expect(assigns(:additional_detail).errors).to be_blank
            expect(response).to redirect_to(additional_detail_service_additional_details_path(@core_service))
            #expect(assigns(:service)).to_not be_blank
            #expect(assigns(:additional_detail)).to be_blank
          }.to change(AdditionalDetail, :count).by(1)
        end
  
        it 'see failed validation for :description being too long' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "0"*256, :form_definition_json => "{}", :effective_date => Date.today, :enabled => "true"}
            })
            expect(assigns(:additional_detail).errors[:description].size).to eq(1)
            message = "is too long (maximum is 255 characters)"
            expect(assigns(:additional_detail).errors[:description][0]).to eq(message)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end
  
        it 'see failed validation for blank :name when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Date.tomorrow, :enabled => "true"}
            })
            expect(assigns(:additional_detail).errors[:name].size).to eq(1)
            expect(assigns(:additional_detail).errors[:effective_date].size).to eq(0)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end
  
        it 'see failed validation for blank :effective_date when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => "", :enabled => "true"}
            })
            expect(assigns(:additional_detail).errors[:effective_date].size).to eq(1)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end
  
        it 'see failed validation for blank :effective_date when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => "", :enabled => "true"}
            })
            expect(assigns(:additional_detail).errors[:effective_date].size).to eq(1)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end
  
        it 'see failed validation for :effective_date that is already taken when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Date.tomorrow, :enabled => "true"}
            })
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 2", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Date.tomorrow, :enabled => "true"}
            })
            expect(assigns(:additional_detail).errors[:effective_date].size).to eq(1)
            message = "Effective date cannot be the same as any other effective dates."
            expect(assigns(:additional_detail).errors[:effective_date][0]).to eq(message)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(1)
        end
  
        it 'see failed validation for blank :form_definition_json when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "", :effective_date => Date.today, :enabled => "true"}
            })
            expect(assigns(:additional_detail).errors[:form_definition_json].size).to eq(1)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end
        
        it 'see failed validation for form with no questions :form_definition_json when trying to create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => '{"schema": {"type": "object","title": "Comment","properties": {},"required": []},"form": []}',
              :effective_date => Date.today, :enabled => "true"}
            })
            expect(assigns(:additional_detail).errors[:form_definition_json].size).to eq(1)
            message = "Form must contain at least one question."
            expect(assigns(:additional_detail).errors[:form_definition_json][0]).to eq(message)
            expect(response).to render_template("new")
            expect(response.status).to eq(200)
            expect(assigns(:service)).to_not be_blank
            expect(assigns(:additional_detail)).to_not be_blank
          }.to change(AdditionalDetail, :count).by(0)
        end  

        describe 'view line_item_additional_details' do
          before :each do
            @service_request = ServiceRequest.new
            @service_request.save(validate: false)
            
            @sub_service_request = SubServiceRequest.new
            @sub_service_request.service_request_id = @service_request.id
            @sub_service_request.status = 'first_draft'
            SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
            @sub_service_request.save(:validate => false)
            SubServiceRequest.set_callback(:save, :after, :update_org_tree)

            @line_item = LineItem.new
            @line_item.sub_service_request_id = @sub_service_request.id
            @line_item.service_request = @service_request
            @line_item.service_id = @core_service.id
            @line_item.save(validate: false)

            @line_item_additional_detail = LineItemAdditionalDetail.new
            @line_item_additional_detail.line_item_id = @line_item.id
            @line_item_additional_detail.additional_detail_id = @additional_detail.id
            @line_item_additional_detail.save(validate: false)
          end

          describe "show status" do
            before :each do
              @sub_service_request.status = 'first_draft'
            end
            it "should show additional detail" do
              get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
              expect(response.status).to eq(200)

              expect(JSON.parse(response.body)["line_item_additional_details"][0]["sub_service_request_status"]).to eq(@sub_service_request.status)
            end
          end

          describe 'with owner name present' do
            before :each do
              @owner = Identity.new
              @owner.first_name = "Test"
              @owner.last_name = "Person"
              @owner.email = "test@test.uiowa.edu"
              Identity.skip_callback(:create, :after, :send_admin_mail)
              @owner.save(validate: false)
              Identity.set_callback(:create, :after, :send_admin_mail)

              @service_request.service_requester_id = @owner.id
              @service_request.save(validate: false)
              
            end

            it "should show additional detail" do
              get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
              expect(response.status).to eq(200)
              expect(JSON.parse(response.body)["line_item_additional_details"][0]["service_requester_name"]).to eq("Test Person (test@test.uiowa.edu)")
            end
          end
          
          describe 'with protocol' do
            before :each do
              @protocol = Protocol.new
              @protocol.short_title = "Short Title"
              @protocol.save(validate: false)

              @primary_pi = Identity.new
              @primary_pi.first_name = "Primary"
              @primary_pi.last_name = "Person"
              @primary_pi.email = "test@test.uiowa.edu"
              @primary_pi.save(validate: false)
              
              @project_role_pi = ProjectRole.new
              @project_role_pi.identity = @primary_pi
              @project_role_pi.role = 'primary-pi'        
              @project_role_pi.protocol = @protocol
              @project_role_pi.save(validate: false)    

              @service_request.protocol_id = @protocol.id
              @service_request.save(validate: false)
            end

            it "should show protocol short title and primary_pi" do
              get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
              expect(response.status).to eq(200)
              expect(JSON.parse(response.body)["line_item_additional_details"][0]["protocol_short_title"]).to eq("Short Title")
              expect(JSON.parse(response.body)["line_item_additional_details"][0]["pi_name"]).to eq("Primary Person (test@test.uiowa.edu)")
            end
          end
        end
      end

      describe 'for a program and and has access to' do
        before :each do
          @catalog_manager.organization_id = @program.id
          @catalog_manager.save(validate: false)
        end

        it 'a core service index because user is a catalog_manager for its program' do
          get(:index, {:service_id => @core_service, :format => :html})
          expect(response).to render_template("index")
          expect(response.status).to eq(200)
          expect(assigns(:service)).to_not be_blank
            
          get(:index, {:service_id => @core_service, :format => :json})
          expect(response.status).to eq(200)
          expect(response.body).to eq("["+@additional_detail.to_json(:root => false, :include => :line_item_additional_details)+"]")
        end

        it 'a program service index' do
          get(:index, {:service_id => @program_service, :format => :html})
          expect(response).to render_template("index")
          expect(response.status).to eq(200)
          expect(assigns(:service)).to_not be_blank
            
          get(:index, {:service_id => @program_service, :format => :json})
          expect(response.status).to eq(200)
          expect(response.body).to eq("[]")
        end

        it 'a core service new additional detail page because user is a catalog_manager for its program' do
          get(:new, {:service_id => @core_service, :format => :html})
          expect(response).to render_template("new")
          expect(response.status).to eq(200)
          expect(assigns(:service)).to_not be_blank
          expect(assigns(:additional_detail)).to_not be_blank
        end

        it 'a program service new additional detail page' do
          get(:new, {:service_id => @program_service, :format => :html})
          expect(response).to render_template("new")
          expect(response.status).to eq(200)
          expect(assigns(:service)).to_not be_blank
          expect(assigns(:additional_detail)).to_not be_blank
        end
      end
    end

    describe 'is a core super_user and has access to' do
      before :each do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)
      end
      
      it 'a core service index' do
        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
          
        get(:index, {:service_id => @core_service, :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq("["+@additional_detail.to_json(:root => false, :include => :line_item_additional_details)+"]")
      end

      it 'a core service new additional detail page' do
        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end    
      
      it "duplicate an additional detail" do
        get(:duplicate,{:service_id => @core_service, :id => @additional_detail, :format =>:html})
        expect(response.status).to eq(200)
        expect(response).to render_template(:action => 'new')
      end  
      
      it "show an additional detail" do
        get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
        expect(response.status).to eq(200)
      end
      
      it "update_enabled" do
        put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "false"} })
        expect(response.status).to eq(204)
      end
    end
    
    describe 'is a program super_user and has access to' do
      before :each do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)
      end
      
      it 'a program service index' do
        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
          
        get(:index, {:service_id => @program_service, :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq("[]")
      end

      it 'a program service new additional detail page' do
        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end
      
      it "duplicate an additional detail for a child core service" do
        get(:duplicate,{:service_id => @core_service, :id => @additional_detail, :format =>:html})
        expect(response.status).to eq(200)
        expect(response).to render_template(:action => 'new')
      end  
      
      it "show an additional detail" do
        get(:show, {:service_id => @core_service, :id => @additional_detail, :format => :json })
        expect(response.status).to eq(200)
      end
      
      it "update_enabled" do
        put(:update_enabled, {:service_id => @core_service, :id => @additional_detail, :additional_detail=> @additional_detail.attributes = { :enabled => "false"} })
        expect(response.status).to eq(204)
      end
    end
  end
end
