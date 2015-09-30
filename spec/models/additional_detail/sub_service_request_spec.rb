require 'rails_helper'

RSpec.describe 'SubServiceRequest' do

  describe "get_additional_details" do
    before(:each) do

      @sub_service_request = SubServiceRequest.new
      @sub_service_request.class.skip_callback(:save, :after, :update_org_tree)
      expect{
        @sub_service_request.save(:validate => false)
      }.to change{SubServiceRequest.count}.by(1)

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
      expect(@sub_service_request.get_line_item_additional_details).to eq([])
    end

    describe "when additional details present" do
      before(:each) do
        @ad = AdditionalDetail.new
        @ad.effective_date = Time.now
        @ad.service_id = @service.id
        @ad.save(:validate => false)
      end

      it "should return array of additional details" do
        expect(@sub_service_request.get_additional_details).to eq([@ad])
      end

      it "a new line_item_additional_detail_should be created and returned in the array" do
        expect{@sub_service_request.get_line_item_additional_details}.to change{LineItemAdditionalDetail.count}.by(1)
        @liad = LineItemAdditionalDetail.where(:line_item_id => @line_item.id)
        expect{expect(@sub_service_request.get_line_item_additional_details).to eq(@liad)}.to change{LineItemAdditionalDetail.count}.by(0)
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
          @ad2.effective_date = Time.now
          @ad2.service_id = @service2.id
          @ad2.save(:validate => false)
        end

        it "should return multiple additional details" do
          expect(@sub_service_request.get_additional_details).to eq([@ad, @ad2])
        end
        
        it "should return multiple line_item_additional_details" do 
          expect{@sub_service_request.get_line_item_additional_details}.to change{LineItemAdditionalDetail.count}.by(2)
          @liad = LineItemAdditionalDetail.where(:line_item_id => @line_item.id)
          @liad2 = LineItemAdditionalDetail.where(:line_item_id => @line_item2.id)
          results =[]
          results.concat(@liad)
          results.concat(@liad2)
          expect{expect(@sub_service_request.get_line_item_additional_details).to eq(results)}.to change{LineItemAdditionalDetail.count}.by(0)
        end
      
      end
      
    end
  end

end