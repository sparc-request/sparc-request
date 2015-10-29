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

    it 'should fail validation when :effective_date is null' do
      @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
      @ad.name = "Name"
      expect(!@ad.valid?)
      expect(@ad.errors[:effective_date].size).to eq(1)
      message = "can't be blank"
      expect(@ad.errors[:effective_date][0]).to eq(message)
    end

    it 'should fail validation when :effective_date is in the past' do
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

    it 'should fail validation when :name is null' do
      @ad.effective_date= Date.today
      @ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":"{test}","required":[]},"form":[]}'
      expect(!@ad.valid?)
      expect(@ad.errors[:name].size).to eq(1)
      message = "can't be blank"
      expect(@ad.errors[:name][0]).to eq(message)
    end

    it 'should fail validation when :form_definition_json is null' do
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

    it 'should fail validation when :form_definition_json has no questions with white space' do
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

    it 'should fail validation when :description is too long' do
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
  
  describe 'schema_hash and form_array' do    
    it 'should return empty hash and empty array when each is empty' do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{ "schema": {}, "form": []}'
      expect(@additional_detail.schema_hash).to eq({})
      expect(@additional_detail.form_array).to eq([])
    end
    
    it 'should return hash and array for one field' do
      @additional_detail = AdditionalDetail.new
      @additional_detail.form_definition_json= '{"schema":{"type":"object","title":"Comment","properties":{"birthdate":{"title":"birthdate","description":"ex. 06/13/2015","type":"string","format":"datepicker","validationMessage":"Please enter vaild date ex. 06/13/2015"}},"required":[]},"form":[{"key":"birthdate","kind":"datepicker","style":{"selected":"btn-success","unselected":"btn-default"},"type":"datepicker","dateOptions":{"dateFormat":"MM/dd/yyyy"}}]}'
      expect(@additional_detail.schema_hash).to eq({"type"=>"object","title"=>"Comment","properties"=>{"birthdate"=>{"title"=>"birthdate","description"=>"ex. 06/13/2015","type"=>"string","format"=>"datepicker","validationMessage"=>"Please enter vaild date ex. 06/13/2015"}},"required"=>[]})
      expect(@additional_detail.form_array).to eq([{"key"=>"birthdate","kind"=>"datepicker","style"=>{"selected"=>"btn-success","unselected"=>"btn-default"},"type"=>"datepicker","dateOptions"=>{"dateFormat"=>"MM/dd/yyyy"}}])
    end
  end
  
  describe "export_array" do
    before :each do
      @primary_pi = Identity.new
      @primary_pi.first_name = "Primary"
      @primary_pi.last_name = "Investigator"
      @primary_pi.email = "pi@test.edu"
           
      @project_role_pi = ProjectRole.new
      @project_role_pi.identity = @primary_pi
      @project_role_pi.role = 'primary-pi'
         
      @protocol = Protocol.new
      @protocol.short_title = "Super Short Title"
      @protocol.project_roles << @project_role_pi
      
      @service_requester = Identity.new
      @service_requester.first_name = "Requester"
      @service_requester.last_name = "Person"
      @service_requester.email = "requester@test.edu"
      
      @sub_service_request = SubServiceRequest.new
      @sub_service_request.status = 'first_draft'
      @sub_service_request.id = 1
           
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
    
    it "should return one additional details export info with no line item additional detail info" do
      expect(@additional_detail.export_array.length).to eq(1)
      expect(@additional_detail.export_array[0]).to include(
        "Additional-Detail" => "BMI / Consulting / Project Team Members", 
        "Effective-Date" => Date.today,
        "SSR-ID" => 1,
        "SSR-Status" => "first_draft",
        "Requester-Name" => "Requester Person (requester@test.edu)",
        "PI-Name" => "Primary Investigator (pi@test.edu)",
        "Protocol-Short-Title" => "Super Short Title",
        "Required-Questions-Answered" => false
        # updated_at
      )
    end
  end
end
