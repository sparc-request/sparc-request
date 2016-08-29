# coding: utf-8
# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe 'PricingMap' do

  describe "validations" do
    let!(:core)          { create(:core) }
    let!(:service)       { create(:service, organization_id: core.id) }

    it "should not raise exception if full_rate, display_date, and effective_date are set" do
      expect { create(:pricing_map, full_rate: 100, display_date: Date.today - 2.days,
                                  effective_date: Date.today - 2.days, service_id: service.id).save! }.not_to raise_exception
    end

    it "should validate the presence of full rate" do
      expect { create(:pricing_map, full_rate: nil, display_date: Date.today - 2.days,
                                  effective_date: Date.today - 2.days, service_id: service.id).save! }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "should validate the numericality of full rate" do
      expect { create(:pricing_map, full_rate: "hello", display_date: Date.today - 2.days,
                                  effective_date: Date.today - 2.days, service_id: service.id).save! }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "should validate the presence of display_date" do
      expect { create(:pricing_map, full_rate: 100, display_date: nil,
                                  effective_date: Date.today - 2.days, service_id: service.id).save! }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "should validate the presence of effective_date" do
      expect { create(:pricing_map, full_rate: 100, display_date: Date.today - 2.days,
                                  effective_date: nil, service_id: service.id).save! }.to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
  
  describe "is_one_time_fee?" do
    it 'should return true' do
      service = Service.new
      service.one_time_fee = true
      service.save(validate: false)
      
      pricing_map = service.pricing_maps.new
      expect(pricing_map.is_one_time_fee?).to eq(true)
    end
      
    it 'should return false if one_time_fee is false' do
      service = Service.new
      service.one_time_fee = false
      service.save(validate: false)
      
      pricing_map = service.pricing_maps.new
      expect(pricing_map.is_one_time_fee?).to eq(false)
    end
    
    it 'should return nil if service is nil' do      
      pricing_map = PricingMap.new
      expect(pricing_map.is_one_time_fee?).to eq(nil)
    end
  end
  
  describe "dynamic validations" do       
    # test all of the validations for two scenarios: 1) the service has already been saved and 2) the service has yet to be saved
    service_saved = [true, false]
    service_saved.each do |persist_service| 
      describe "for one time fee with service saved=#{persist_service}" do
        before :each do
          @service = Service.new
          @service.one_time_fee = true
          if persist_service
            @service.save(validate: false)
          end
        end
        # One time fee pricing maps require: units_per_qty_max, otf_unit_type, quantity_type, and quantity_minimum  
        it 'should all pass' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => 52, :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => 1,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(true)
        end
        
        it 'should require presence of unit_factor' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => nil, 
                                  # one time fee specific fields
                                  :units_per_qty_max => 12, :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => 1,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:unit_factor].count).to eq(2)
          expect(pricing_map.errors.count).to eq(2)
        end
        
        it 'should require that unit_factor be numeric' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "adsfasdfsdf", 
                                  # one time fee specific fields
                                  :units_per_qty_max => 12, :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => 1,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:unit_factor].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require units_per_qty_max' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => nil, :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => 1,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:units_per_qty_max].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require that units_per_qty_max be an integer not a string' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => "not a number", :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => 1,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:units_per_qty_max].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require that units_per_qty_max be an integer not a decimal' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => 12.23, :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => 1,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:units_per_qty_max].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require presence of otf_unit_type' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => 12, :otf_unit_type => nil, :quantity_type => "hours", :quantity_minimum => 1,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:otf_unit_type].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require presence of quantity_type' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => 12, :otf_unit_type => "N/A", :quantity_type => nil, :quantity_minimum => 1,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:quantity_type].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require presence of quantity_minimum' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => 12, :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => nil,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:quantity_minimum].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require that quantity_minimum be an integer not a string' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => 12, :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => "adsfasd",
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:quantity_minimum].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require that quantity_minimum be an integer not a decimal' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => 12, :otf_unit_type => "N/A", :quantity_type => "hours", :quantity_minimum => 56.78,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:quantity_minimum].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
      end
      
      describe "for per patient" do
        before :each do
          @service = Service.new
          @service.one_time_fee = false
          @service.save(validate: false)
        end
        # Per patient pricing maps require: unit_type and unit_minimum
        it 'should all pass' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => nil, :otf_unit_type => nil, :quantity_type => nil, :quantity_minimum => nil,
                                  # per patient specific fields
                                  :unit_type => "Per Infusion", :unit_minimum => 1)
          expect(pricing_map.valid?).to eq(true)
        end
        
        it 'should require presence of unit_factor' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => nil, 
                                  # one time fee specific fields
                                  :units_per_qty_max => nil, :otf_unit_type => nil, :quantity_type => nil, :quantity_minimum => nil,
                                  # per patient specific fields
                                  :unit_type => "Per Infusion", :unit_minimum => 1)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:unit_factor].count).to eq(2)
          expect(pricing_map.errors.count).to eq(2)
        end
        
        it 'should require that unit_factor be numeric' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "abad", 
                                  # one time fee specific fields
                                  :units_per_qty_max => nil, :otf_unit_type => nil, :quantity_type => nil, :quantity_minimum => nil,
                                  # per patient specific fields
                                  :unit_type => "Per Infusion", :unit_minimum => 1)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:unit_factor].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end      
        
        it 'should require presence of unit_type' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => nil, :otf_unit_type => nil, :quantity_type => nil, :quantity_minimum => nil,
                                  # per patient specific fields
                                  :unit_type => nil, :unit_minimum => 1)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:unit_type].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require presence of unit_minimum' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => nil, :otf_unit_type => nil, :quantity_type => nil, :quantity_minimum => nil,
                                  # per patient specific fields
                                  :unit_type => "Per Infusion", :unit_minimum => nil)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:unit_minimum].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require unit_minimum be an integer not a string' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => nil, :otf_unit_type => nil, :quantity_type => nil, :quantity_minimum => nil,
                                  # per patient specific fields
                                  :unit_type => "Per Infusion", :unit_minimum => "asdfasdfasd")
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:unit_minimum].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
        
        it 'should require unit_minimum be an integer not a decimal' do
          pricing_map = @service.pricing_maps.build(:display_date => Date.today - 2.days, :effective_date => Date.today - 2.days,:full_rate => 100,
                                  :unit_factor => "1", 
                                  # one time fee specific fields
                                  :units_per_qty_max => nil, :otf_unit_type => nil, :quantity_type => nil, :quantity_minimum => nil,
                                  # per patient specific fields
                                  :unit_type => "Per Infusion", :unit_minimum => 12.34)
          expect(pricing_map.valid?).to eq(false)
          expect(pricing_map.errors[:unit_minimum].count).to eq(1)
          expect(pricing_map.errors.count).to eq(1)
        end
      end
    end
  end
  
  describe 'applicable_rate' do
    it 'should return the full rate if full rate is requested' do
      pricing_map = create(:pricing_map)
      pricing_map.full_rate = "60.0"
      expect(pricing_map.applicable_rate('full', 100)).to eq(60)
    end

    it 'should return the full rate times the given percentage if there is no override' do
      pricing_map = create(:pricing_map)
      pricing_map.full_rate = "60.0"
      expect(pricing_map.applicable_rate('federal', 0.7)).to eq(42.0)
    end

    it 'should return the override rate if there is one' do
      pricing_map = create(:pricing_map)
      pricing_map.full_rate = "60.0"
      pricing_map.federal_rate = 10.0
      expect(pricing_map.applicable_rate('federal', 0.7)).to eq(10.0)
    end
  end

  describe 'rate_override' do
    [
      'full',
      'federal',
      'corporate',
      'member',
      'other'
    ].each do |rate_type|
      it "should return the #{rate_type} rate override if rate type is #{rate_type}" do
        pricing_map = create(:pricing_map)
        pricing_map.federal_rate = 10.0
        pricing_map.corporate_rate = 10.0
        pricing_map.other_rate = 10.0
        pricing_map.member_rate = 10.0
        eval("pricing_map.#{rate_type}_rate = 42.0")
        expect(pricing_map.rate_override(rate_type)).to eq(42.0)
      end
    end
  end

  describe 'calculate_rate' do
    it 'should return the full rate times the given percentage' do
      pricing_map = create(:pricing_map)
      pricing_map.full_rate = "60.0"
      expect(pricing_map.calculate_rate(0.7)).to eq(42.0)
    end
  end

  describe 'rates from full' do

    let!(:core)          { create(:core) }
    let!(:service)       { create(:service, organization_id: core.id) }
    let!(:pricing_map)   { create(:pricing_map, full_rate: 100, display_date: Date.today - 2.days,
                           effective_date: Date.today - 2.days, service_id: service.id) }
    let!(:pricing_setup) { create(:pricing_setup, display_date: Date.today - 1.day, federal: 25,
                           effective_date: Date.today - 1.day, corporate: 25, other: 25, member: 25, organization_id: core.id)}

    it 'should return a hash with the correct rates' do
      ps = PricingSetup.find(pricing_setup.id)
      hash = { federal_rate: 25, corporate_rate: 25, other_rate: 25, member_rate: 25 }
      # pricing_map.rates_from_full(ps.display_date).should eq(hash)
      PricingMap.rates_from_full(ps.display_date, core.id, 100)
    end
  end
end
