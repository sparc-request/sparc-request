require 'rails_helper'

RSpec.describe "Line Item" do

  describe "get_additional_detail" do
    before(:each) do
      @service = Service.new
      @service.save(:validate => false)
      
      @line_item = LineItem.new
      @line_item.service_id = @service.id
      @line_item.save(:validate => false)
    end
    
      it "should return nil when no additional details present" do
        expect(@line_item.get_additional_detail).to eq(nil)
      end
      
      it "should return nil for get_line_item_additional_detail if no additional detail present" do
        expect(@line_item.get_or_create_line_item_additional_detail).to eq(nil)
      end
    
      describe 'with a line additional detail present' do
        before(:each) do
          @ad = AdditionalDetail.new
          @ad.effective_date = Date.today
          @ad.service_id = @service.id
          @ad.save(:validate => false)
        end
        
        it "should return an additional detail " do
          expect(@line_item.get_additional_detail).to eq(@ad)
        end
         
        it "should return additional detail with most recent active " do 
          @ad2 = AdditionalDetail.new
          @ad2.effective_date = Date.yesterday
          @ad2.service_id = @service.id
          @ad2.save(:vailidate => false)
          
          expect(@line_item.get_additional_detail).to eq(@ad)
          
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
    
end
