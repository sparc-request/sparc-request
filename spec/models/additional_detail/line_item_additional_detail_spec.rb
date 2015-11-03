require 'spec_helper'

RSpec.describe LineItemAdditionalDetail do

  describe "validation" do

    before :each do
      @additional_detail = AdditionalDetail.new
      @line_item = LineItem.new
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
      @line_item_additional_detail.additional_detail = @additional_detail
    end

    it 'should succeed on create if form_data_json is nil' do
      expect(@line_item_additional_detail.save()).to eq(true)
    end

    it 'form_data_json should default to {}' do
      @line_item_additional_detail.save(vailidate: false)
      expect(@line_item_additional_detail.form_data_json).to eq("{}")
    end

    it 'should succeed on update if form_data_json is NOT empty' do
      @line_item_additional_detail.save()
      expect(@line_item_additional_detail.update_attributes({ :form_data_json => '{ "real" : "JSON" }'})).to eq(true)
    end

    it 'should fail on update if form_data_json equals the word "null"' do
      @line_item_additional_detail.save()
      expect(@line_item_additional_detail.update_attributes({ :form_data_json => "null"})).to eq(false)
      expect(@line_item_additional_detail.errors[:form_data_json]).to eq(["must be valid JSON"])
    end

    it 'should fail on update if form_data_json is not valid JSON' do
      @line_item_additional_detail.save()
      expect(@line_item_additional_detail.update_attributes({ :form_data_json => "{ asdfasdf : {"})).to eq(false)
      expect(@line_item_additional_detail.errors[:form_data_json]).to eq(["must be valid JSON"])
    end
  end

  describe "additional_detail_description" do
    before :each do
      @additional_detail = AdditionalDetail.new
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.additional_detail = @additional_detail
    end
    
    it 'should return nil when description is nil' do
      expect(@line_item_additional_detail.additional_detail_description).to eq(nil)
    end
    
    it 'should return nil if somehow additional detail is nil' do
      @line_item_additional_detail.additional_detail = nil
      expect(@line_item_additional_detail.additional_detail_description).to eq(nil)
    end
  
    it 'should return value' do
      @additional_detail.description = "Important form to fill out."
      expect(@line_item_additional_detail.additional_detail_description).to eq("Important form to fill out.")
    end
  end
  
  describe "has_answered_all_required_questions?" do

    before :each do
      @additional_detail = AdditionalDetail.new
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.additional_detail = @additional_detail
    end

    describe "with no required fields" do
      before :each do
        @additional_detail.form_definition_json= '{"schema": {"required": [] }}'
      end

      it 'should return true when form_data_json is nil' do
        @line_item_additional_detail.form_data_json = nil
        expect(@line_item_additional_detail.has_answered_all_required_questions?).to eq(true)
      end
      
      it 'should return true when no questions are answered' do
        @line_item_additional_detail.form_data_json = "{}"
        expect(@line_item_additional_detail.has_answered_all_required_questions?).to eq(true)
      end

      it 'should return true with questions answered' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test."}'
        expect(@line_item_additional_detail.has_answered_all_required_questions?).to eq(true)
      end

    end

    describe "with one required fields" do
      before :each do
        @additional_detail.form_definition_json= '{"schema": {"required": ["t"] }}'
      end

      it 'should return false when not all data is present' do
        @line_item_additional_detail.form_data_json = "{}"
        expect(@line_item_additional_detail.has_answered_all_required_questions?).to eq(false)
      end

      it 'should return true when all data is present' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test."}'
        expect(@line_item_additional_detail.has_answered_all_required_questions?).to eq(true)
      end

    end

    describe "with two required fields" do
      before :each do
        @additional_detail.form_definition_json= '{"schema": {"required": ["t","r"] }}'
      end

      it 'should return false when only one question is present' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test.", "s" : "Hello world!"}'
        expect(@line_item_additional_detail.has_answered_all_required_questions?).to eq(false)
      end

      it 'should return true when all questions is present' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test.", "r" : "World, hello!"}'
        expect(@line_item_additional_detail.has_answered_all_required_questions?).to eq(true)
      end
    end
  end

  describe "sub_service_request_status" do
    before :each do
      @sub_service_request = SubServiceRequest.new
      @sub_service_request.status = 'first_draft'

      @line_item = LineItem.new
      @line_item.sub_service_request = @sub_service_request

      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
    end

    it 'should return the status of the sub_service_request' do
      expect(@line_item_additional_detail.sub_service_request_status).to eq(@sub_service_request.status)
    end
  end
  
  describe "sub_service_request_id" do
    before :each do
      @sub_service_request = SubServiceRequest.new
      @sub_service_request.status = 'first_draft'
      @sub_service_request.id = 1
      
      @line_item = LineItem.new
      @line_item.sub_service_request = @sub_service_request

      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
    end

    it 'should return the id of the sub_service_request' do
      expect(@line_item_additional_detail.sub_service_request_id).to eq(1)
    end
  end

  describe "details_hash" do

    it 'should return a hash with zero key/value pairs' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.form_data_json = "{}"
      expect(@line_item_additional_detail.form_data_hash).to eq({})
    end

    it 'should return a hash with one key/value pair' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.form_data_json = "{\"date\":\"10/13/2015\"}"
      expect(@line_item_additional_detail.form_data_hash).to eq({ "date" => "10/13/2015" })
    end

    it 'should return a hash with two key/value pairs' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.form_data_json = "{\"date\":\"10/13/2015\", \"email\":\"test@test.com\"}"
      expect(@line_item_additional_detail.form_data_hash).to eq({ "date" => "10/13/2015", "email" => "test@test.com" })
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
      
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
    end
    
    it "protocol_short_title should return short title of protocol" do
      expect(@line_item_additional_detail.protocol_short_title).to eq(@protocol.short_title)
    end
    
    it "pi_name should return the name of the primary investigator" do
      expect(@line_item_additional_detail.pi_name).to eq("Primary Person (test@test.uiowa.edu)")
    end
  end
  

  describe "service_requester_name" do
    before :each do
      @service_requester =  Identity.new

      @service_request = ServiceRequest.new
      @service_request.service_requester = @service_requester

      @line_item = LineItem.new
      @line_item.service_request = @service_request

      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
    end

    describe "with first and last name" do
      before :each do
        @service_requester.first_name = "Test"
        @service_requester.last_name = "Person"
        @service_requester.email = "test@test.uiowa.edu"
      end

      it 'should return first and last name of service_requester' do
        expect(@line_item_additional_detail.service_requester_name).to eq("Test Person (test@test.uiowa.edu)")
      end
    end

    describe "with only first name" do
      before :each do
        @service_requester.first_name = "Test"
      end

      it 'should return first name of service_requester' do
        expect(@line_item_additional_detail.service_requester_name).to eq("Test  ()")
      end
    end

    describe "with only last name" do
      before :each do
        @service_requester.last_name = "Person"
      end

      it 'should return last name of service_requester' do
        expect(@line_item_additional_detail.service_requester_name).to eq("Person ()")
      end
    end

    describe "with no first or last name or email" do
      it 'should return nil' do
        expect(@line_item_additional_detail.service_requester_name).to eq("()")
      end
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

      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
      expect(@line_item_additional_detail.additional_detail_breadcrumb).to eq("REDCap / New Project / ")
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

      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
      expect(@line_item_additional_detail.additional_detail_breadcrumb).to eq("REDCap / New Project / Project Details")
    end

    it 'should return program / service, without additional detail name' do
      @line_item = LineItem.new
      @line_item.service = Service.new
      @line_item.service.name = "Consulting"
      @line_item.service.organization = Program.new
      @line_item.service.organization.type = "Program"
      @line_item.service.organization.name = "BMI"

      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
      expect(@line_item_additional_detail.additional_detail_breadcrumb).to eq("BMI / Consulting / ")
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

      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
      expect(@line_item_additional_detail.additional_detail_breadcrumb).to eq("BMI / Consulting / Project Team Members")
    end
  end
  
  describe 'additional_detail_schema_hash and additional_detail_form_array' do
    it 'should return empty hash and empty array when additional_detail is nil' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      expect(@line_item_additional_detail.additional_detail_schema_hash).to eq({})
      expect(@line_item_additional_detail.additional_detail_form_array).to eq([])
    end
    
    it 'should return empty hash and empty array when each is empty' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.additional_detail = AdditionalDetail.new
      @line_item_additional_detail.additional_detail.form_definition_json= '{ "schema": {}, "form": []}'
      expect(@line_item_additional_detail.additional_detail_schema_hash).to eq({})
      expect(@line_item_additional_detail.additional_detail_form_array).to eq([])
    end
    
    it 'should return hash and array for one field' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.additional_detail = AdditionalDetail.new
      @line_item_additional_detail.additional_detail.form_definition_json = '{"schema":{"type":"object","title":"Comment","properties":{"birthdate":{"title":"birthdate","description":"ex. 06/13/2015","type":"string","format":"datepicker","validationMessage":"Please enter vaild date ex. 06/13/2015"}},"required":[]},"form":[{"key":"birthdate","kind":"datepicker","style":{"selected":"btn-success","unselected":"btn-default"},"type":"datepicker","dateOptions":{"dateFormat":"MM/dd/yyyy"}}]}'
      expect(@line_item_additional_detail.additional_detail_schema_hash).to eq({"type"=>"object","title"=>"Comment","properties"=>{"birthdate"=>{"title"=>"birthdate","description"=>"ex. 06/13/2015","type"=>"string","format"=>"datepicker","validationMessage"=>"Please enter vaild date ex. 06/13/2015"}},"required"=>[]})
      expect(@line_item_additional_detail.additional_detail_form_array).to eq([{"key"=>"birthdate","kind"=>"datepicker","style"=>{"selected"=>"btn-success","unselected"=>"btn-default"},"type"=>"datepicker","dateOptions"=>{"dateFormat"=>"MM/dd/yyyy"}}])
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
      
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
    end
    
    it "should return empty protocol id followed by empty SRID" do
      expect(@line_item_additional_detail.srid).to eq("-")
    end
    
    it "should return protocol id followed by SRID" do
      @service_request.protocol = @protocol
      @sub_service_request.ssr_id = "0002"
      expect(@line_item_additional_detail.srid).to eq("1-0002")
    end
  end       
  
  describe "export_hash" do
    before :each do
      @primary_pi = Identity.new
      @primary_pi.first_name = "Primary"
      @primary_pi.last_name = "Investigator"
      @primary_pi.email = "pi@test.edu"
           
      @project_role_pi = ProjectRole.new
      @project_role_pi.identity = @primary_pi
      @project_role_pi.role = 'primary-pi'
         
      @protocol = Protocol.new
      @protocol.id = 10
      @protocol.short_title = "Super Short Title"
      @protocol.project_roles << @project_role_pi
      
      @service_requester = Identity.new
      @service_requester.first_name = "Requester"
      @service_requester.last_name = "Person"
      @service_requester.email = "requester@test.edu"
      
      @sub_service_request = SubServiceRequest.new
      @sub_service_request.status = 'first_draft'
      @sub_service_request.id = 1
      @sub_service_request.ssr_id = "0005"
           
      @line_item = LineItem.new
      @line_item.service_request = ServiceRequest.new
      @line_item.service_request.service_requester = @service_requester
      @line_item.service_request.protocol = @protocol
      @line_item.sub_service_request = @sub_service_request
      @line_item.service = Service.new
      @line_item.service.name = "Consulting"
      @line_item.service.organization = Program.new
      @line_item.service.organization.type = "Program"
      @line_item.service.organization.name = "BMI"
      
      @additional_detail = AdditionalDetail.new
      @additional_detail.name = "Project Team Members"
      @additional_detail.enabled = true
      @additional_detail.effective_date = Date.today
      @additional_detail.form_definition_json = '{"schema": {"required": ["birthdate", "email"] }, "form":[{"key":"birthdate"},{"key":"email"},{"key":"firstName"} ]}'
      @line_item.service.additional_details << @additional_detail
      
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
      @line_item_additional_detail.form_data_json = '{}'
      @line_item_additional_detail.additional_detail = @additional_detail
      @additional_detail.line_item_additional_details << @line_item_additional_detail 
    end
    
    it "should return additional details export info with no line item additional detail info" do
      expect(@line_item_additional_detail.export_hash).to include(
        "Additional-Detail" => "BMI / Consulting / Project Team Members", 
        "Effective-Date" => Date.today,
        "Srid" => "10-0005",
        "Ssr-Status" => "first_draft",
        "Requester-Name" => "Requester Person (requester@test.edu)",
        "Pi-Name" => "Primary Investigator (pi@test.edu)",
        "Protocol-Short-Title" => "Super Short Title",
        "Required-Questions-Answered" => false,
        "Last-Updated-At" => "",
        "birthdate" => "",
        "email" => "",
        "firstName" => ""
      )
    end
    
    it "should return additional details export info with one email answered from line item additional detail info" do
      @line_item_additional_detail.form_data_json = '{"email" : "test@test.edu"}'
      
      expect(@line_item_additional_detail.export_hash).to include(
        "Additional-Detail" => "BMI / Consulting / Project Team Members", 
        "Effective-Date" => Date.today,
        "Srid" => "10-0005",
        "Ssr-Status" => "first_draft",
        "Requester-Name" => "Requester Person (requester@test.edu)",
        "Pi-Name" => "Primary Investigator (pi@test.edu)",
        "Protocol-Short-Title" => "Super Short Title",
        "Required-Questions-Answered" => false,
        "Last-Updated-At" => "",
        "birthdate" => "",
        "email" => "test@test.edu",
        "firstName" => ""
      )
    end
    
    it "should return additional details export info with both required questions answered from line item additional detail info" do
      @line_item_additional_detail.form_data_json = '{"firstName" : "Test Subject", "email" : "test@test.edu", "birthdate":"03/01/1978"}'
      
      expect(@line_item_additional_detail.export_hash).to include(
        "Additional-Detail" => "BMI / Consulting / Project Team Members", 
        "Effective-Date" => Date.today,
        "Srid" => "10-0005",
        "Ssr-Status" => "first_draft",
        "Requester-Name" => "Requester Person (requester@test.edu)",
        "Pi-Name" => "Primary Investigator (pi@test.edu)",
        "Protocol-Short-Title" => "Super Short Title",
        "Required-Questions-Answered" => true,
        "Last-Updated-At" => "",
        "birthdate" => "03/01/1978",
        "email" => "test@test.edu",
        "firstName" => "Test Subject"
      )
    end
    
    it "should return additional details export info with all three required questions answered from line item additional detail info" do
      @line_item_additional_detail.form_data_json = '{"email" : "test@test.edu", "birthdate":"03/01/1978"}'
      
      expect(@line_item_additional_detail.export_hash).to include(
        "Additional-Detail" => "BMI / Consulting / Project Team Members", 
        "Effective-Date" => Date.today,
         "Srid" => "10-0005",
        "Ssr-Status" => "first_draft",
        "Requester-Name" => "Requester Person (requester@test.edu)",
        "Pi-Name" => "Primary Investigator (pi@test.edu)",
        "Protocol-Short-Title" => "Super Short Title",
        "Required-Questions-Answered" => true,
        "Last-Updated-At" => "",
        "birthdate" => "03/01/1978",
        "email" => "test@test.edu",
        "firstName" => ""
      )
    end
    
    it "should return blank Last-Updated-At for nil updated_at" do
      @line_item_additional_detail.updated_at = nil
      
      expect(@line_item_additional_detail.export_hash).to include(
        "Additional-Detail" => "BMI / Consulting / Project Team Members", 
        "Effective-Date" => Date.today,
        "Srid" => "10-0005",
        "Ssr-Status" => "first_draft",
        "Requester-Name" => "Requester Person (requester@test.edu)",
        "Pi-Name" => "Primary Investigator (pi@test.edu)",
        "Protocol-Short-Title" => "Super Short Title",
        "Required-Questions-Answered" => false,
        "Last-Updated-At" => "",
        "birthdate" => "",
        "email" => "",
        "firstName" => ""
      )
    end
  end
end
