require 'rails_helper'

RSpec.describe 'SubServiceRequest' do

  describe "get_additional_details" do
    before(:each) do

      @sub_service_request = SubServiceRequest.new
      SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
      expect{
        @sub_service_request.save(:validate => false)
      }.to change{SubServiceRequest.count}.by(1)
      SubServiceRequest.set_callback(:save, :after, :update_org_tree)

      @service = Service.new
      expect{
        @service.save(:validate => false)
      }.to change{Service.count}.by(1)

      @line_item = LineItem.new
      @line_item.service_id = @service.id
      @line_item.sub_service_request_id = @sub_service_request.id
      expect{
        @line_item.save(:validate => false)
      }.to change{LineItem.count}.by(1)
    end

    it "should return an empty array if no additionl details present" do
      expect(@sub_service_request.get_additional_details).to eq([])
    end

    it "should return empty array for line_item_additional_details when no additional details are present" do
      expect(@sub_service_request.get_or_create_line_item_additional_details).to eq([])
    end

    describe "when additional details present" do
      before(:each) do
        @ad = AdditionalDetail.new
        @ad.effective_date = Date.yesterday
        @ad.service_id = @service.id
        @ad.save(:validate => false)
      end

      it "should return array of additional details" do
        expect(@sub_service_request.get_additional_details).to eq([@ad])
      end

      it "a new line_item_additional_detail_should be created and returned in the array" do
        expect{@sub_service_request.get_or_create_line_item_additional_details}.to change{LineItemAdditionalDetail.count}.by(1)
        @liad = LineItemAdditionalDetail.where(:line_item_id => @line_item.id)
        expect{expect(@sub_service_request.get_or_create_line_item_additional_details).to eq(@liad)}.to change{LineItemAdditionalDetail.count}.by(0)
      end

      describe "when  multiple additional details present" do
        before(:each) do
          @service2 = Service.new
          @service2.save(:validate => false)

          @line_item2 = LineItem.new
          @line_item2.service_id = @service2.id
          @line_item2.sub_service_request_id = @sub_service_request.id
          @line_item2.save(:validate => false)

          @ad2 = AdditionalDetail.new
          @ad2.effective_date = Date.yesterday
          @ad2.service_id = @service2.id
          @ad2.save(:validate => false)
        end

        it "should return multiple additional details" do
          expect(@sub_service_request.get_additional_details).to eq([@ad, @ad2])
        end
        
        it "should return multiple line_item_additional_details" do 
          expect{@sub_service_request.get_or_create_line_item_additional_details}.to change{LineItemAdditionalDetail.count}.by(2)
          @liad = LineItemAdditionalDetail.where(:line_item_id => @line_item.id)
          @liad2 = LineItemAdditionalDetail.where(:line_item_id => @line_item2.id)
          results =[]
          results.concat(@liad)
          results.concat(@liad2)
          expect{expect(@sub_service_request.get_or_create_line_item_additional_details).to eq(results)}.to change{LineItemAdditionalDetail.count}.by(0)
        end
      
      end
      
    end
  end

  describe "additional_details_required_questions_answered?" do
    before :each do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{"schema": {"required": ["t","date"] }}'
  
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.additional_detail = @additional_detail 
     
      @line_item = LineItem.new
      @line_item.line_item_additional_detail = @line_item_additional_detail
      
      @sub_service_request = SubServiceRequest.new
      @sub_service_request.line_items << @line_item
    end
    
    it 'should return false when two required questions and no data has been submitted' do
      @line_item_additional_detail.form_data_json = "{}"
      expect(@sub_service_request.additional_details_required_questions_answered?).to eq(false)
    end
    
    it 'should return false when one of two required questions has been answered' do
      @line_item_additional_detail.form_data_json = '{"t" : "This is a test."}'
      expect(@sub_service_request.additional_details_required_questions_answered?).to eq(false)
    end
    
    it 'should return true when both required questions have been answered' do
      @line_item_additional_detail.form_data_json = '{"t" : "This is a test.", "date" : "2015-10-15"}'
      expect(@sub_service_request.additional_details_required_questions_answered?).to eq(true)
    end
    
    it 'should return true when zero questions are required and no data has been submitted' do
      @additional_detail.form_definition_json= '{"schema": {"required": [] }}'
      @line_item_additional_detail.form_data_json = '{}'
      expect(@sub_service_request.additional_details_required_questions_answered?).to eq(true)
    end
    
    describe "a sub service request with two line items, each with a different additional detail" do
      before :each do
        @additional_detail_two = AdditionalDetail.new
        @additional_detail_two.form_definition_json= '{"schema": {"required": ["email","firstName"] }}'
        
        @line_item_additional_detail_two = LineItemAdditionalDetail.new
        @line_item_additional_detail_two.additional_detail = @additional_detail_two 
       
        @line_item_two = LineItem.new
        @line_item_two.line_item_additional_detail = @line_item_additional_detail_two
        
        @sub_service_request.line_items << @line_item_two
      end
      
      it 'should return false when four total required questions and no data has been submitted' do
        @line_item_additional_detail.form_data_json = "{}"
        @line_item_additional_detail_two.form_data_json = "{}"
        expect(@sub_service_request.additional_details_required_questions_answered?).to eq(false)
      end
      
      it 'should return false when two of four total required questions has been answered' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test."}'
        @line_item_additional_detail_two.form_data_json = '{"firstName" : "Robert"}'
        expect(@sub_service_request.additional_details_required_questions_answered?).to eq(false)
      end
      
      it 'should return false when three of four total required questions have been answered, missing data in first form' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test."}'
        @line_item_additional_detail_two.form_data_json = '{"email" : "test@test.com", "firstName" : "Robert"}'
        expect(@sub_service_request.additional_details_required_questions_answered?).to eq(false)
      end
      
      it 'should return false when three of four total required questions have been answered, missing data in second form' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test.", "date" : "2015-10-15"}'
        @line_item_additional_detail_two.form_data_json = '{ "firstName" : "Robert"}'
        expect(@sub_service_request.additional_details_required_questions_answered?).to eq(false)
      end
      
      it 'should return true when all four required questions have been answered' do
        @line_item_additional_detail.form_data_json = '{"t" : "This is a test.", "date" : "2015-10-15"}'
        @line_item_additional_detail_two.form_data_json = '{"email" : "test@test.com", "firstName" : "Robert"}'
        expect(@sub_service_request.additional_details_required_questions_answered?).to eq(true)
      end
      
      it 'should return true when zero questions are required and no data has been submitted' do
        @additional_detail.form_definition_json= '{"schema": {"required": [] }}'
        @additional_detail_two.form_definition_json= '{"schema": {"required": [] }}'
        @line_item_additional_detail.form_data_json = '{}'
        @line_item_additional_detail_two.form_data_json = '{}'
        expect(@sub_service_request.additional_details_required_questions_answered?).to eq(true)
      end
    end
  end       

end