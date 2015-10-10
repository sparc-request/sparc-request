# coding: utf-8
# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.describe "Line Item" do

  describe "get_additional_detail" do
    before(:each) do
      @service = Service.new
      @service.save(:validate => false)
      
      @line_item = LineItem.new
      @line_item.service_id = @service.id
      @line_item.save(:validate => false)
    end
    
      it "should return nil when no additional details present" do
        expect(@line_item.get_additional_detail).to eq(nil)
      end
      
      it "should return nil for get_line_item_additional_detail if no additional detail present" do
        expect(@line_item.get_or_create_line_item_additional_detail).to eq(nil)
      end
    
      describe 'with a line additional detail present' do
        before(:each) do
          @ad = AdditionalDetail.new
          @ad.effective_date = 1.day.ago
          @ad.service_id = @service.id
          @ad.save(:validate => false)
        end
        
        it "should return an additional detail " do
          expect(@line_item.get_additional_detail).to eq(@ad)
        end
         
        it "should return additional detail with most recent active " do 
          @ad2 = AdditionalDetail.new
          @ad2.effective_date = 2.day.ago
          @ad2.service_id = @service.id
          @ad2.save(:vailidate => false)
          
          expect(@line_item.get_additional_detail).to eq(@ad)
          
        end
        
        it "should create a new line_item_additional detail when none is present" do
          expect{
            @line_item_additional_detail = @line_item.get_or_create_line_item_additional_detail
          }.to change{LineItemAdditionalDetail.count}.by(1)
                   
          @line_item_additional_detail.additional_detail_id = @ad.id
          @line_item_additional_detail.line_item_id = @line_item.id
        end
        
      it "should not create a new line_item_additional_detail when one already exists" do
        @line_item_additional_detail = LineItemAdditionalDetail.new
        @line_item_additional_detail.additional_detail_id = @ad.id
        @line_item_additional_detail.line_item_id = @line_item.id
        @line_item_additional_detail.save
        
        expect{
          @liad = @line_item.get_or_create_line_item_additional_detail
        }.to change{LineItemAdditionalDetail.count}.by(0)
        
        @liad.additional_detail_id = @ad.id
        @liad.line_item_id = @line_item.id
      end
        
      end
      
  end
  
end
