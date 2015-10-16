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

  describe "required_fields_present" do
    
    before :each do
     @additional_detail = AdditionalDetail.new
     @additional_detail.form_definition_json= '{"schema": {"required": ["t"] }}'

     @line_item_additional_detail = LineItemAdditionalDetail.new
     @line_item_additional_detail.additional_detail = @additional_detail
    end
    
    it 'should return false when not all data is present' do
      @line_item_additional_detail.form_data_json = "{}"
      expect(@line_item_additional_detail.required_fields_present).to eq(false)
    end
    
    it 'should return true when all data is present' do
          @line_item_additional_detail.form_data_json = '{"t" : "This is a test."}'
          expect(@line_item_additional_detail.required_fields_present).to eq(true)
    end
    
    describe "with two required fields" do
      before :each do
        @additional_detail.form_definition_json= '{"schema": {"required": ["t","r"] }}'
      end
      
      it 'should return false when only one question is present' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test.", "s" : "Hello world!"}'
        expect(@line_item_additional_detail.required_fields_present).to eq(false)
      end
      
      it 'should return false when only one question is present' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test.", "r" : "World, hello!"}'
        expect(@line_item_additional_detail.required_fields_present).to eq(true)
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
      @additional_detail.effective_date = Date.today
      
      @line_item.service.additional_details << @additional_detail
      
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item = @line_item
      expect(@line_item_additional_detail.additional_detail_breadcrumb).to eq("BMI / Consulting / Project Team Members")
    end    
  end  
  
end

