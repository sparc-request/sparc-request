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
    
    it 'should fail on update if form_data_json is not present' do
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.line_item_id = @line_item.id
      @line_item_additional_detail.additional_detail_id = @additional_detail.id
      @line_item_additional_detail.save(:validate => false)
      
      expect(@line_item_additional_detail.update_attributes({})).to eq(false)
      expect(@line_item_additional_detail.errors[:form_data_json]).to eq(["can't be blank"])
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
end
