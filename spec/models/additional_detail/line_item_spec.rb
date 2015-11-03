require 'rails_helper'

RSpec.describe "Line Item" do

  describe "get_or_create_line_item_additional_detail" do
    before(:each) do
      @service = Service.new
      @service.save(:validate => false)
      
      @line_item = LineItem.new
      @line_item.service_id = @service.id
      @line_item.save(:validate => false)
    end
      
      it "should return nil for get_line_item_additional_detail if no additional detail present" do
        expect(@line_item.get_or_create_line_item_additional_detail).to eq(nil)
      end
    
      describe 'with a line additional detail present' do
        before(:each) do
          @ad = AdditionalDetail.new
          @ad.enabled = true
          @ad.effective_date = Date.today
          @ad.service_id = @service.id
          @ad.save(:validate => false)
        end
        
        it "should create a new line_item_additional detail when none is present" do
          expect{
            @line_item_additional_detail = @line_item.get_or_create_line_item_additional_detail
          }.to change{LineItemAdditionalDetail.count}.by(1)
                   
          @line_item_additional_detail.additional_detail_id = @ad.id
          @line_item_additional_detail.line_item_id = @line_item.id
        end
        
        it "should not create a new line_item_additional_detail when one already exists" do
          @line_item_additional_detail = LineItemAdditionalDetail.new
          @line_item_additional_detail.additional_detail_id = @ad.id
          @line_item_additional_detail.line_item_id = @line_item.id
          @line_item_additional_detail.save
          
          expect{
            @liad = @line_item.get_or_create_line_item_additional_detail
          }.to change{LineItemAdditionalDetail.count}.by(0)
          
          @liad.additional_detail_id = @ad.id
          @liad.line_item_id = @line_item.id
        end
      end
  end
  
  describe "additional_details_hash" do
    it 'should return a hash with zero key/value pairs because LineItemAdditionalDetail is nil' do
      @line_item = LineItem.new
      expect(@line_item.additional_details_form_data_hash).to eq({})
    end
    
    it 'should return a hash with zero key/value pairs because LineItemAdditionalDetail is empty' do
      @line_item = LineItem.new
      @line_item.line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item.line_item_additional_detail.form_data_json = "{}"
      expect(@line_item.additional_details_form_data_hash).to eq({})
    end
    
    it 'should return a hash with one key/value pair' do
      @line_item = LineItem.new
      @line_item.line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item.line_item_additional_detail.form_data_json = "{\"date\":\"10/13/2015\"}"
      expect(@line_item.additional_details_form_data_hash).to eq({ "date" => "10/13/2015" })
    end
    
    it 'should return a hash with two key/value pairs' do
      @line_item = LineItem.new
      @line_item.line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item.line_item_additional_detail.form_data_json = "{\"date\":\"10/13/2015\", \"email\":\"test@test.com\"}"
      expect(@line_item.additional_details_form_data_hash).to eq({ "date" => "10/13/2015", "email" => "test@test.com" })
    end
  end

  describe "additional_detail_breadcrumb" do
     
    it 'should return core / service, without additional detail name' do
      @line_item = LineItem.new
      @line_item.service = Service.new
      @line_item.service.name = "New Project"
      @line_item.service.organization = Core.new
      @line_item.service.organization.type = "Core"
      @line_item.service.organization.name = "REDCap"
                  
      expect(@line_item.additional_detail_breadcrumb).to eq("REDCap / New Project / ")
    end
    
    it 'should return core / service / additional detail name' do
      @line_item = LineItem.new
      @line_item.service = Service.new
      @line_item.service.name = "New Project"
      @line_item.service.organization = Core.new
      @line_item.service.organization.type = "Core"
      @line_item.service.organization.name = "REDCap"
        
      @additional_detail = AdditionalDetail.new
      @additional_detail.name = "Project Details"
      @additional_detail.enabled = true
      @additional_detail.effective_date = Date.today
      
      @line_item.service.additional_details << @additional_detail
              
      expect(@line_item.additional_detail_breadcrumb).to eq("REDCap / New Project / Project Details")
    end
  
    it 'should return program / service, without additional detail name' do
      @line_item = LineItem.new
      @line_item.service = Service.new
      @line_item.service.name = "Consulting"
      @line_item.service.organization = Program.new
      @line_item.service.organization.type = "Program"
      @line_item.service.organization.name = "BMI"
            
      expect(@line_item.additional_detail_breadcrumb).to eq("BMI / Consulting / ")
    end
    
    it 'should return program / service / additional detail name' do
      @line_item = LineItem.new
      @line_item.service = Service.new
      @line_item.service.name = "Consulting"
      @line_item.service.organization = Program.new
      @line_item.service.organization.type = "Program"
      @line_item.service.organization.name = "BMI"
                  
      @additional_detail = AdditionalDetail.new
      @additional_detail.name = "Project Team Members"
      @additional_detail.enabled = true
      @additional_detail.effective_date = Date.today
      
      @line_item.service.additional_details << @additional_detail
      
      expect(@line_item.additional_detail_breadcrumb).to eq("BMI / Consulting / Project Team Members")
    end    
  end  
  
  describe "additional_detail_required_questions_answered?" do
    before :each do
      @service = Service.new
      
      @line_item = LineItem.new
      @line_item.service = @service
      
      @additional_detail = AdditionalDetail.new
      @additional_detail.enabled = true
      @additional_detail.effective_date = Date.yesterday
    end
    
    describe "line_item_additional_detail not yet created," do
      
      it 'should return true when no line_item_additional_detail exists and the service does not have an additional detail' do
        expect(@line_item.additional_detail_required_questions_answered?).to eq(true)
      end
      
      it 'should return true when no line_item_additional_detail exists and the service has an additional detail with no required questions' do
        @additional_detail.form_definition_json= '{"schema": {"required": [] }}'
        @service.additional_details << @additional_detail 
        expect(@line_item.additional_detail_required_questions_answered?).to eq(true)
      end
      
      it 'should return false when no line_item_additional_detail exists and the service has an additional detail with required questions' do
        @additional_detail.form_definition_json= '{"schema": {"required": ["t","date"] }}'
        @service.additional_details << @additional_detail 
        expect(@line_item.additional_detail_required_questions_answered?).to eq(false)
      end
    end
    
    describe "line_item_additional_detail created" do
      before :each do  
        @additional_detail.form_definition_json= '{"schema": {"required": ["t","date"] }}'
        @service.additional_details << @additional_detail 

        # add a line_item_additional_detail
        @line_item_additional_detail = LineItemAdditionalDetail.new
        @line_item_additional_detail.additional_detail = @additional_detail 
        @line_item.line_item_additional_detail = @line_item_additional_detail
      end
      
      it 'should return false when two required questions and no data has been submitted' do
        @line_item_additional_detail.form_data_json = "{}"
        expect(@line_item.additional_detail_required_questions_answered?).to eq(false)
      end
      
      it 'should return false when one of two required questions has been answered' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test."}'
        expect(@line_item.additional_detail_required_questions_answered?).to eq(false)
      end
      
      it 'should return true when both required questions have been answered' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test.", "date" : "2015-10-15"}'
        expect(@line_item.additional_detail_required_questions_answered?).to eq(true)
      end
      
      it 'should return true when zero questions are required' do
        @additional_detail.form_definition_json= '{"schema": {"required": [] }}'
        @line_item_additional_detail.form_data_json = '{}'
        expect(@line_item.additional_detail_required_questions_answered?).to eq(true)
      end
    end
    
  end  

  describe "protocol short_title and pi_name" do
    before :each do
      @primary_pi = Identity.new
      @primary_pi.first_name = "Primary"
      @primary_pi.last_name = "Person"
      @primary_pi.email = "test@test.uiowa.edu"
           
      @project_role_pi = ProjectRole.new
      @project_role_pi.identity = @primary_pi
      @project_role_pi.role = 'primary-pi'
         
      @protocol = Protocol.new
      @protocol.short_title = "Super Short Title"
      @protocol.project_roles << @project_role_pi
      
      @service_request = ServiceRequest.new
      @service_request.protocol = @protocol
      
      @line_item = LineItem.new
      @line_item.service_request = @service_request
    end
    
    it "protocol_short_title should return short title of protocol" do
      expect(@line_item.protocol_short_title).to eq(@protocol.short_title)
    end
    
    it "pi_name should return the name of the primary investigator" do
      expect(@line_item.pi_name).to eq("Primary Person (test@test.uiowa.edu)")
    end
  end
  
  describe "service_requester_name" do
    before :each do
      @service_requester =  Identity.new
  
      @service_request = ServiceRequest.new
      @service_request.service_requester = @service_requester
  
      @line_item = LineItem.new
      @line_item.service_request = @service_request
    end
  
    describe "with first and last name" do
      before :each do
        @service_requester.first_name = "Test"
        @service_requester.last_name = "Person"
        @service_requester.email = "test@test.uiowa.edu"
      end
  
      it 'should return first and last name of service_requester' do
        expect(@line_item.service_requester_name).to eq("Test Person (test@test.uiowa.edu)")
      end
    end
  
    describe "with only first name" do
      before :each do
        @service_requester.first_name = "Test"
      end
  
      it 'should return first name of service_requester' do
        expect(@line_item.service_requester_name).to eq("Test  ()")
      end
    end
  
    describe "with only last name" do
      before :each do
        @service_requester.last_name = "Person"
      end
  
      it 'should return last name of service_requester' do
        expect(@line_item.service_requester_name).to eq("Person ()")
      end
    end
  
    describe "with no first or last name or email" do
      it 'should return nil' do
        expect(@line_item.service_requester_name).to eq("()")
      end
    end
  end

  describe "srid" do
    before :each do         
      @protocol = Protocol.new
      @protocol.id = 1      
      
      @service_request = ServiceRequest.new      
      @sub_service_request = SubServiceRequest.new
      
      @line_item = LineItem.new
      @line_item.service_request = @service_request
      @line_item.sub_service_request = @sub_service_request
    end
    
    it "should return empty protocol id followed by empty SRID" do
      expect(@line_item.srid).to eq("-")
    end
    
    it "should return protocol id followed by SRID" do
      @service_request.protocol = @protocol
      @sub_service_request.ssr_id = "0002"
      expect(@line_item.srid).to eq("1-0002")
    end
    
    it "should return protocol id followed by empty SRID" do
      @service_request.protocol = @protocol
      expect(@line_item.srid).to eq("1-")
    end
    
    it "should return empty protocol id followed by SRID" do
      @sub_service_request.ssr_id = "0002"
      expect(@line_item.srid).to eq("-0002")
    end
  end        
end
