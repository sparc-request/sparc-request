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

    it 'should fail vailidation when :form_definition_json is null' do
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
