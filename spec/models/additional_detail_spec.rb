require 'spec_helper'

describe AdditionalDetail do

  before :each do
    @institution = Institution.new
    @institution.type = "Institution"
    @institution.abbreviation = "TECHU"
    @institution.save(validate: false)

    @provider = Provider.new
    @provider.type = "Provider"
    @provider.abbreviation = "ICTS"
    @provider.parent_id = @institution.id
    @provider.save(validate: false)

    @program = Program.new
    @program.type = "Program"
    @program.name = "BMI"
    @program.parent_id = @provider.id
    @program.save(validate: false)

    @core = Core.new
    @core.type = "Core"
    @core.name = "REDCap"
    @core.parent_id = @program.id
    @core.save(validate: false)

    @core_service = Service.new
    @core_service.organization_id = @core.id
    @core_service.save(validate: false)

    @program_service = Service.new
    @program_service.organization_id = @program.id
    @program_service.save(validate: false)
  end

  describe "model" do
    it 'should create new additional detail' do
      ad = AdditionalDetail.new
      ad.service_id= @core_service.id
      ad.effective_date= Time.now
      ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":{test},"required":[]},"form":[]}'
      ad.name = "Name"
      expect(ad.valid?)
      expect(ad.errors.count).to eq(0)
    end

    it 'should fail vailidation when :effective_date is null' do
      ad = AdditionalDetail.new
      ad.service_id= @core_service.id
      ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":{test},"required":[]},"form":[]}'
      ad.name = "Name"
      expect(!ad.valid?)
      expect(ad.errors[:effective_date].size).to eq(1)
      message = "can't be blank"
      expect(ad.errors[:effective_date][0]).to eq(message)
    end

    it 'should fail vailidation when :effective_date is too far in the past' do
      ad = AdditionalDetail.new
      ad.service_id= @core_service.id
      ad.effective_date= 1.day.ago
      ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":{test},"required":[]},"form":[]}'
      ad.name = "Name"
      expect(!ad.valid?)
      expect(ad.errors[:effective_date].size).to eq(1)
      message = "Date must be in past."
      expect(ad.errors[:effective_date][0]).to eq(message)
    end

    it 'should fail vailidation when :name is null' do
      ad = AdditionalDetail.new
      ad.service_id= @core_service.id
      ad.effective_date= Time.now
      ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":{test},"required":[]},"form":[]}'
      expect(!ad.valid?)
      expect(ad.errors[:name].size).to eq(1)
      message = "can't be blank"
      expect(ad.errors[:name][0]).to eq(message)
    end

    it 'should fail vailidation when :form_definition_json is null' do
      ad = AdditionalDetail.new
      ad.service_id= @core_service.id
      ad.effective_date= Time.now
      ad.name= "Test"
      expect(!ad.valid?)
      expect(ad.errors[:form_definition_json].size).to eq(1)
      message = "can't be blank"
      expect(ad.errors[:form_definition_json][0]).to eq(message)
    end

    it 'should fail vailidation when line_item_additional_details are present' do
      count = AdditionalDetail.count
      ad = AdditionalDetail.new
      ad.service_id= @core_service.id
      ad.effective_date= Time.now
      ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":{test},"required":[]},"form":[]}'
      ad.name = "Name"
      expect(ad.valid?)
      expect(ad.errors.count).to eq(0)
      ad.save
      expect(AdditionalDetail.count).to eq(count+1)
      
      line_count = LineItemAdditionalDetail.count
      liad = LineItemAdditionalDetail.new
      liad.additional_detail_id = ad.id
      liad.save(validate: false)
      expect(LineItemAdditionalDetail.count).to eq(line_count+1)

      l = LineItemAdditionalDetail.where(id: liad.id)
      expect(!l.nil?)
      
      ad2 = AdditionalDetail.find(ad.id)
      ad2.name = "Name 2"
      ad2.save
      expect(AdditionalDetail.count).to eq(count+1)
      expect(!ad2.valid?)
      expect(ad2.errors[:form_definition_json].size).to eq(1)
      message = "Cannot be edited when response has been saved."
      expect(ad2.errors[:form_definition_json][0]).to eq(message)
    end

    it 'should fail vailidation when :form_definition_json has no questions with white space' do
      ad = AdditionalDetail.new
      ad.form_definition_json = '  {"schema": {"type":   "object","title":
        "Comment","properties": {},"required": []}
      ,"form": []}  '
      ad.service_id= @core_service.id
      ad.effective_date= Time.now
      ad.name= "Test"
      expect(!ad.valid?)
      expect(ad.errors[:form_definition_json].size).to eq(1)
      message = "Form must contain at least one question."
      expect(ad.errors[:form_definition_json][0]).to eq(message)
    end

    it 'should fail vailidation when :description is too long' do
      ad = AdditionalDetail.new
      ad.form_definition_json ='{"schema":{"type":"object","title":"Comment","properties":{test},"required":[]},"form":[]}'
      ad.service_id= @core_service.id
      ad.effective_date= Time.now
      ad.description = "0"*256
      ad.name= "Test"
      expect(!ad.valid?)
      expect(ad.errors[:description].size).to eq(1)
      message = "is too long (maximum is 255 characters)"
      expect(ad.errors[:description][0]).to eq(message)
    end

  end

end
