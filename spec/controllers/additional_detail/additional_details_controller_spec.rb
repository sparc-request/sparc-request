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

    @program_service = Service.new
    @program_service.organization_id = @program.id
    @program_service.save(validate: false)
  end

  describe 'user is not logged in and, thus, has no access to' do
    it 'a core service index' do
      get(:index, {:service_id => @core_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end

    it 'a program service index' do
      get(:index, {:service_id => @program_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end

    it 'a core service new additional detail page' do
      get(:new, {:service_id => @core_service, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
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

    describe 'is not a catalog_manager or super_user and, thus, has no access to' do
      it 'a core service index' do
        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        #expect(assigns(:service)).to be_blank
      end

      it 'a core service index even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)

        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
      end

      it 'a program service index' do
        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
      end

      it 'a program service index even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)

        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
      end

      it 'a new core service additional detail page' do
        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end

      it 'a new core service additional detail page even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @core.id
        @service_provider.save(validate: false)

        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end

      it 'a new program service additional detail page' do
        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
      end

      it 'a new program service additional detail page even if user is a service provider' do
        @service_provider = ServiceProvider.new
        @service_provider.identity_id = @identity.id
        @service_provider.organization_id = @program.id
        @service_provider.save(validate: false)

        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("unauthorized")
        expect(response.status).to eq(401)
        expect(assigns(:service)).to be_blank
        expect(assigns(:additional_detail)).to be_blank
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
        end
     
        it 'a core service new additional detail page' do
          get(:new, {:service_id => @core_service, :format => :html})
          expect(response).to render_template("new")
          expect(response.status).to eq(200)
          expect(assigns(:service)).to_not be_blank
          expect(assigns(:additional_detail)).to_not be_blank
        end
        
        describe 'with an additional detail present' do
          before :each do
            @ad = AdditionalDetail.new
            @ad.service_id = @core_service.id
            @ad.form_definition_json= '{"schema": {"required": ["t","date"] }}'
            @ad.save(validate: false)
          end
          
          it "should delete" do
            expect{
              delete(:destroy, {:service_id => @core_service, :id => @ad, :format => :json})
              expect(response.status).to eq(204)
            }.to change(AdditionalDetail, :count).by(-1)
          end
          
          describe 'with line_item_additional_details present' do
            before :each do
              @sub_service_request = SubServiceRequest.new
              @sub_service_request.status = 'first_draft'
              SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
              @sub_service_request.save(:validate => false)
              SubServiceRequest.set_callback(:save, :after, :update_org_tree)
              
              @line_item = LineItem.new
              @line_item.sub_service_request_id = @sub_service_request.id
              @line_item.service_id = @core_service.id
              @line_item.save(validate: false)
              
              @line_item_additional_detail = LineItemAdditionalDetail.new
              @line_item_additional_detail.line_item_id = @line_item.id
              @line_item_additional_detail.additional_detail_id = @ad.id
              @line_item_additional_detail.save(validate: false)
            end
            
            it "should show additional detail" do
              get(:show, {:service_id => @core_service, :id => @ad, :format => :json })
              expect(response.status).to eq(200)
              expect(response.body).to eq(@ad.to_json(:root => false, :include => {:line_item_additional_details  => {:methods => [:sub_service_request_status, :has_answered_all_required_questions?]}}))
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
        end
        
        it 'a program service index' do
          get(:index, {:service_id => @program_service, :format => :html})
          expect(response).to render_template("index")
          expect(response.status).to eq(200)
          expect(assigns(:service)).to_not be_blank
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
                 
      # CRUD an additional detail as a catalog_manager
      describe 'a core service and can' do
        before :each do
          @catalog_manager = CatalogManager.new
          @catalog_manager.identity_id = @identity.id
          @catalog_manager.organization_id = @core.id
          @catalog_manager.save(validate: false)
        end
        
        describe 'with an additional detail present' do
          before :each do
            @ad = AdditionalDetail.new
            @ad.name = "Test"
            @ad.service_id = @core_service.id
            @ad.form_definition_json= '{"schema": {"required": ["t","date"] }}'
            @ad.effective_date = Date.today
            @ad.approved = "false"
            expect{
              @ad.save
            }.to change(AdditionalDetail, :count).by(1)
          end

          it "can duplicate" do
            get(:duplicate,{:service_id => @core_service, :id => @ad, :format =>:html})
            expect(response.status).to eq(200)
            expect(response).to render_template(:action => 'new')
            expect(assigns(:additional_detail).name).to eq(@ad.name)
            expect(assigns(:additional_detail).form_definition_json).to eq(@ad.form_definition_json)
            expect(assigns(:additional_detail).effective_date).to eq(@ad.effective_date)
            expect(assigns(:additional_detail).approved).to eq(@ad.approved)
          end
          
          it "can update" do 
            put(:update, {:service_id => @core_service, :id => @ad, :additional_detail=> @ad.attributes = { :name => "Test2"} }) 
            expect(response).to redirect_to(additional_detail_service_additional_details_path(@core_service))
            expect(AdditionalDetail.find(@ad.id).name).to eq("Test2")
          end
          
          it "can delete" do 
            expect{
              delete(:destroy, {:service_id => @core_service, :id => @ad, :format => :json})
              expect(response.status).to eq(204)    
            }.to change(AdditionalDetail, :count).by(-1)
          end
          
          it "will render edit page" do
            get(:edit,{:service_id => @core_service, :id => @ad, :format =>:html})
            expect(response.status).to eq(200)
            expect(response).to render_template(:action => 'new')
          end
          
          describe 'with a line item additional detail present' do
            before :each do
              @line_item_additional_detail = LineItemAdditionalDetail.new
              @line_item_additional_detail.additional_detail_id = @ad.id
              @line_item_additional_detail.save(validate: false)
            end
            
            it "cannot delete" do
              expect{
                delete(:destroy, {:service_id => @core_service, :id => @ad, :format => :json})
                expect(response.status).to eq(403)
              }.to change(AdditionalDetail, :count).by(0)
            end
            
            it "cannot update" do
              put(:update, {:service_id => @core_service, :id => @ad, :additional_detail=> @ad.attributes = { :name => "Test2"} }) 
              expect(response.status).to eq(403)
              expect(AdditionalDetail.find(@ad.id).name).to eq("Test")
              end
             
            it "will not render the edit page" do
              get(:edit,{:service_id => @core_service, :id => @ad, :format =>:html})
              expect(response.status).to eq(401)
              expect(response).to render_template("unauthorized", :status => :unauthorized)
            end
               
          end

        end

        it 'create an additional detail record' do
          expect {
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Date.tomorrow, :approved => "true"}
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
              :additional_detail => {:name => "Form # 1", :description => "0"*256, :form_definition_json => "{}", :effective_date => Date.today, :approved => "true"}
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
              :additional_detail => {:name => "", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Date.tomorrow, :approved => "true"}
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
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => "", :approved => "true"}
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
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => "", :approved => "true"}
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
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Date.tomorrow, :approved => "true"}
            })
            post(:create, {:service_id => @core_service, :format => :html,
              :additional_detail => {:name => "Form # 2", :description => "10 essential questions", :form_definition_json => "{}", :effective_date => Date.tomorrow, :approved => "true"}
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
              :additional_detail => {:name => "Form # 1", :description => "10 essential questions", :form_definition_json => "", :effective_date => Date.today, :approved => "true"}
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
              :effective_date => Date.today, :approved => "true"}
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

      end

    end

    describe 'is a super_user and has access to' do
      it 'a core service index' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)

        get(:index, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
      end

      it 'a program service index' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)

        get(:index, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("index")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
      end

      it 'a core service new additional detail page' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @core.id
        @super_user.save(validate: false)

        get(:new, {:service_id => @core_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end

      it 'a program service new additional detail page' do
        @super_user = SuperUser.new
        @super_user.identity_id = @identity.id
        @super_user.organization_id = @program.id
        @super_user.save(validate: false)

        get(:new, {:service_id => @program_service, :format => :html})
        expect(response).to render_template("new")
        expect(response.status).to eq(200)
        expect(assigns(:service)).to_not be_blank
        expect(assigns(:additional_detail)).to_not be_blank
      end
    end
  end
end
