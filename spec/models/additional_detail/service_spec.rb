require 'date'
# not needed for this test right now: require 'rails_helper'

RSpec.describe Service do #, type: :model

  describe 'additional_detail_for_date/current_additional_detail' do
    before :each do
      @service = Service.new
    end

    it 'should return nil if no additional detail present' do
      expect(@service.current_additional_detail).to eq(nil)
    end

    describe 'with an additional detail present with a current effective date' do
      before :each do
        @ad = AdditionalDetail.new
        @ad.effective_date = Date.today
        @service.additional_details << @ad
      end

      it 'should return an additional detail' do
        expect(@service.current_additional_detail).to eq(@ad)
      end

      it 'should return the most recent additional detail' do
        @ad2 = AdditionalDetail.new
        @ad2.effective_date = Date.yesterday
        @service.additional_details << @ad2
        @service.current_additional_detail
        expect(@service.current_additional_detail).to eq(@ad)
      end

      it 'should not return additional details with effective dates in the future' do
        @ad2 = AdditionalDetail.new
        @ad2.effective_date = Date.tomorrow
        @service.additional_details << @ad2
        expect(@service.current_additional_detail).to eq(@ad)
      end
    end
  end

  describe 'additional detail breadcrumb' do
    before :each do  
      @program = Program.new
      @program.type = "Program"
  
      @core = Core.new
      @core.type = "Core"
      
      @program.cores << @core
    end
    
    it 'should return core / service, without additional detail name' do
      @core.name = "REDCap"
      
      @core_service = Service.new
      @core_service.name = "New Project"
      @core_service.organization = @core
                  
      expect(@core_service.additional_detail_breadcrumb).to eq("REDCap / New Project / ")
    end
    
    it 'should return service name only if core name is nil and without additional detail name' do      
      @core_service = Service.new
      @core_service.name = "New Project"
      @core_service.organization = @core
      
      expect(@core_service.additional_detail_breadcrumb).to eq("New Project / ")
    end
    
    it 'should return core / service / additional detail name' do
      @core.name = "REDCap"
      
      @core_service = Service.new
      @core_service.name = "New Project"
      @core_service.organization = @core
      
      @additional_detail = AdditionalDetail.new
      @additional_detail.name = "Project Details"
      @additional_detail.effective_date = Date.today
      @core_service.additional_details << @additional_detail
            
      expect(@core_service.additional_detail_breadcrumb).to eq("REDCap / New Project / Project Details")
    end
    
    
    it 'should return service name only if program name is nil and without additional detail name' do
      @program_service = Service.new
      @program_service.name = "Consulting"
      @program_service.organization = @program
            
      expect(@program_service.additional_detail_breadcrumb).to eq("Consulting / ")
    end
        
    it 'should return program / service, without additional detail name' do
      @program.name = "BMI"

      @program_service = Service.new
      @program_service.name = "Consulting"
      @program_service.organization = @program
            
      expect(@program_service.additional_detail_breadcrumb).to eq("BMI / Consulting / ")
    end
    
    it 'should return program / service / additional detail name' do
      @program.name = "BMI"

      @program_service = Service.new
      @program_service.name = "Consulting"
      @program_service.organization = @program
                  
      @additional_detail = AdditionalDetail.new
      @additional_detail.name = "Project Team Members"
      @additional_detail.effective_date = Date.today
      @program_service.additional_details << @additional_detail
      
      expect(@program_service.additional_detail_breadcrumb).to eq("BMI / Consulting / Project Team Members")
    end
    
    it 'should return orphaned service name / additional detail name' do
      @orphaned_service = Service.new
      @orphaned_service.name = "Consulting Only"
      
      @additional_detail = AdditionalDetail.new
      @additional_detail.name = "Email List"
      @additional_detail.effective_date = Date.today
      @orphaned_service.additional_details << @additional_detail
            
      expect(@orphaned_service.additional_detail_breadcrumb).to eq("Consulting Only / Email List")
    end
    
    it 'should return additional detail name if orphaned service has no name' do
      @orphaned_service = Service.new
      
      @additional_detail = AdditionalDetail.new
      @additional_detail.name = "Email List"
      @additional_detail.effective_date = Date.today
      @orphaned_service.additional_details << @additional_detail
            
      expect(@orphaned_service.additional_detail_breadcrumb).to eq("Email List")
    end
    
    it 'should return orphaned service name, without additional detail name' do
      @orphaned_service = Service.new
      @orphaned_service.name = "Consulting Only"

      expect(@orphaned_service.additional_detail_breadcrumb).to eq("Consulting Only / ")
    end
    
    it 'should return orphaned service name, if additional detail name is nil' do
      @orphaned_service = Service.new
      @orphaned_service.name = "Consulting Only"
      
      @additional_detail = AdditionalDetail.new
      @additional_detail.effective_date = Date.today
      @orphaned_service.additional_details << @additional_detail

      expect(@orphaned_service.additional_detail_breadcrumb).to eq("Consulting Only / ")
    end
    
    it 'should return empty string if orphaned service has no name' do
      @orphaned_service = Service.new

      expect(@orphaned_service.additional_detail_breadcrumb).to eq("")
    end
  end
end
