require 'spec_helper'

RSpec.describe LineItemAdditionalDetail do

  describe "validation" do

    before :each do
      @additional_detail = AdditionalDetail.new
      @additional_detail.save(:validate => false)

      @line_item = LineItem.new
      @line_item.save(:validate => false)
    end

    it 'should succeed on create if form_data_json is nil' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.additional_detail_id = @additional_detail.id

      expect(@line_item_additional_detail.save()).to eq(true)
    end

    it 'form_data_json should default to {}' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.additional_detail_id = @additional_detail.id
      @line_item_additional_detail.save(:validate => false)

      expect(@line_item_additional_detail.form_data_json).to eq("{}")
    end

    it 'should fail on update if form_data_json is nil' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.additional_detail_id = @additional_detail.id
      @line_item_additional_detail.save(:validate => false)

      expect(@line_item_additional_detail.update_attributes({ :form_data_json => nil})).to eq(false)
      expect(@line_item_additional_detail.errors[:form_data_json]).to eq(["can't be blank"])
    end

    it 'should fail on update if form_data_json is empty' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.additional_detail_id = @additional_detail.id
      @line_item_additional_detail.save(:validate => false)

      expect(@line_item_additional_detail.update_attributes({ :form_data_json => ""})).to eq(false)
      expect(@line_item_additional_detail.errors[:form_data_json]).to eq(["can't be blank"])
    end

    it 'should succeed on update if form_data_json is NOT empty' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.additional_detail_id = @additional_detail.id
      @line_item_additional_detail.save(:validate => false)

      expect(@line_item_additional_detail.update_attributes({ :form_data_json => '{ "real" : "JSON" }'})).to eq(true)
    end

    it 'should fail on update if form_data_json equals the word "null"' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.additional_detail_id = @additional_detail.id
      @line_item_additional_detail.save(:validate => false)

      expect(@line_item_additional_detail.update_attributes({ :form_data_json => "null"})).to eq(false)
      expect(@line_item_additional_detail.errors[:form_data_json]).to eq(["must be valid JSON"])
    end

    it 'should fail on update if form_data_json is not valid JSON' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.additional_detail_id = @additional_detail.id
      @line_item_additional_detail.save(:validate => false)

      expect(@line_item_additional_detail.update_attributes({ :form_data_json => "{ asdfasdf : {"})).to eq(false)
      expect(@line_item_additional_detail.errors[:form_data_json]).to eq(["must be valid JSON"])
    end
  end

  describe "get_sub_service_request_status" do

    before :each do
      @sub_service_request = SubServiceRequest.new
      @sub_service_request.status = 'first_draft'
      SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
      @sub_service_request.save(:validate => false)
      SubServiceRequest.set_callback(:save, :after, :update_org_tree)

      @line_item = LineItem.new
      @line_item.sub_service_request_id = @sub_service_request.id
      @line_item.save(:validate => false)

      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.save(:validate => false)
    end

    it 'should return the status of the sub_service_request' do
      expect(@line_item_additional_detail.get_sub_service_request_status).to eq(@sub_service_request.status)
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

end
