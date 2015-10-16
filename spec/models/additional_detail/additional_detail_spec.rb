require 'rails_helper'

RSpec.describe AdditionalDetail do

  describe "validation" do
    before :each do
      @core_service = Service.new
      @core_service.save(validate: false)
      
      @ad = AdditionalDetail.new
      @ad.service_id= @core_service.id
    end

    it 'should create new additional detail' do
      @ad.effective_date= Date.today
      @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
      @ad.name = "Name"
      expect(@ad.valid?)
      expect(@ad.errors.count).to eq(0)
    end

    it 'should fail vailidation when :effective_date is null' do
      @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
      @ad.name = "Name"
      expect(!@ad.valid?)
      expect(@ad.errors[:effective_date].size).to eq(1)
      message = "can't be blank"
      expect(@ad.errors[:effective_date][0]).to eq(message)
    end

    it 'should fail vailidation when :effective_date is not in the past' do
      @ad.effective_date= Date.yesterday
      @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
      @ad.name = "Name"
      expect(!@ad.valid?)
      expect(@ad.errors[:effective_date].size).to eq(1)
      message = "Date cannot be in past."
      expect(@ad.errors[:effective_date][0]).to eq(message)
    end

    it 'update should fail if line item additional details present' do
      @ad.name= "Test"
      @ad.effective_date= Date.today
      @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
      expect{@ad.save}.to change(AdditionalDetail, :count).by(1)
      @line_item_additional_detail = LineItemAdditionalDetail.new
      @line_item_additional_detail.additional_detail_id = @ad.id
      @line_item_additional_detail.save(validate: false)
      @ad.name= "Test 2"
      @ad.save
      expect(AdditionalDetail.find(@ad.id).name).to eq("Test")

    end

    it 'should fail vailidation when :name is null' do
      @ad.effective_date= Date.today
      @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
      expect(!@ad.valid?)
      expect(@ad.errors[:name].size).to eq(1)
      message = "can't be blank"
      expect(@ad.errors[:name][0]).to eq(message)
    end

    it 'should fail vailidation when :form_definition_json is null' do
      @ad.effective_date= Date.today
      @ad.name= "Test"
      expect(!@ad.valid?)
      expect(@ad.errors[:form_definition_json].size).to eq(1)
      message = "can't be blank"
      expect(@ad.errors[:form_definition_json][0]).to eq(message)
    end

    describe "when line_item_additional_detail present" do
      before :each do
        @ad.effective_date= Date.today
        @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
        @ad.name = "Name"
        expect(@ad.valid?)
        expect(@ad.errors.count).to eq(0)
        expect{@ad.save}.to change{AdditionalDetail.count}.by(1)

        @liad = LineItemAdditionalDetail.new
        @liad.additional_detail_id = @ad.id
        expect{@liad.save(validate: false)}.to change{LineItemAdditionalDetail.count}.by(1)
        
      end

      it 'should not be able to update' do
        ad2 = AdditionalDetail.find(@ad.id)
        ad2.name = "Name 2"
        ad2.save
        expect(!ad2.valid?)
      end

      it 'should not be able to delete' do
        count = AdditionalDetail.count
        ad2 = AdditionalDetail.find(@ad.id)
        ad2.destroy
        expect(AdditionalDetail.count).to eq(count)
      end      

    end

    it 'should fail vailidation when :form_definition_json has no questions with white space' do
      @ad.form_definition_json = '  {"schema": {"type":   "object","title":
        "Comment","properties": {},"required": []}
      ,"form": []}  '

      @ad.effective_date= Date.today
      @ad.name= "Test"
      expect(!@ad.valid?)
      expect(@ad.errors[:form_definition_json].size).to eq(1)
      message = "Form must contain at least one question."
      expect(@ad.errors[:form_definition_json][0]).to eq(message)
    end

    it 'should fail vailidation when :description is too long' do
      @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
      @ad.effective_date= Date.today
      @ad.description = "0"*256
      @ad.name= "Test"
      expect(!@ad.valid?)
      expect(@ad.errors[:description].size).to eq(1)
      message = "is too long (maximum is 255 characters)"
      expect(@ad.errors[:description][0]).to eq(message)
    end
  end

  describe 'has_required_questions?' do
    it 'should return false if has zero required questions' do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{"schema": {"required": [] }}'
      expect(@additional_detail.has_required_questions?).to eq(false)
    end
    
    it 'should return true if has one required question' do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{"schema": {"required": ["date"] }}'
      expect(@additional_detail.has_required_questions?).to eq(true)
    end
    
    it 'should return true if has two required questions' do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{"schema": {"required": ["t","date"] }}'
      expect(@additional_detail.has_required_questions?).to eq(true)
    end
  end
  
  describe 'required_question_keys' do
    it 'should return empty array if has zero required questions' do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{"schema": {"required": [] }}'
      expect(@additional_detail.required_question_keys).to eq([])
    end
    
    it 'should return one required question key' do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{"schema": {"required": ["date"] }}'
      expect(@additional_detail.required_question_keys).to eq(["date"])
    end
    
    it 'should return two required question keys' do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{"schema": {"required": ["t","date"] }}'
      expect(@additional_detail.required_question_keys).to eq(["t","date"])
    end
  end
end
