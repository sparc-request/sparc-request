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

require 'spec_helper'

describe "procedure" do

	let_there_be_lane
  let_there_be_j
  build_service_request_with_study
  
  before :each do
	  add_visits
	end

	context "visit schedule methods" do
		let!(:arm)							 { FactoryGirl.create(:arm, name: "Arm IV", protocol_id: protocol_for_service_request_id, visit_count: 1, subject_count: 1)}
		let!(:visit_group)       { FactoryGirl.create(:visit_group, arm_id: arm.id)}
		let!(:visit)             { FactoryGirl.create(:visit, research_billing_qty: 10, insurance_billing_qty: 10, visit_group_id: visit_group.id) }  
		let!(:appointment)       { FactoryGirl.create(:appointment, visit_group_id: visit_group.id) }
		let(:procedure)          { FactoryGirl.create(:procedure, appointment_id: appointment.id, visit_id: visit.id, line_item_id: line_item.id) }
		let(:procedure2)         { FactoryGirl.create(:procedure, appointment_id: appointment.id, visit_id: visit.id, service_id: service2.id) }
		let(:procedure3)         { FactoryGirl.create(:procedure, appointment_id: appointment.id, visit_id: visit.id, service_id: service2.id, line_item_id: line_item.id)}

		describe 'display service name' do

			it 'should return the name of the service if it is attached to a line item' do
				procedure.display_service_name.should eq('One Time Fee')
			end

			it 'should return the name of the service if it is attached to a service' do
				procedure2.display_service_name.should eq('Per Patient')
			end

			it 'should return the name of the service if it is attached to both a service and line item' do
				procedure3.display_service_name.should eq('Per Patient')
			end

		end

		describe 'service core' do

			before :each do
				service2.update_attribute(:organization_id, core.id)
			end

			it "should return the core of the service if it is attached to a line item" do
				procedure.core.should eq(program)
			end

			it "should return the core of the service if it is attached to a service" do
				procedure2.core.should eq(core)
			end

			it "should return the core of the service if it is attached to a service and a line item" do
				procedure3.core.should eq(core)
			end
			
		end

		describe 'default research quantity' do

			context 'when attached to a line item' do
			
				it "should return the visit's research billing quantity if not set" do
					procedure.default_r_quantity.should eq(10)
				end

				it "should return its own quantity if set" do
					procedure.update_attributes(r_quantity: 5)
					procedure.default_r_quantity.should eq(5)
				end

			end

			context 'when attached to a service' do

				it "should return zero if quantity is not set" do
					procedure2.default_r_quantity.should eq(0)
				end

				it "should return its own quantity if set" do
					procedure2.update_attributes(r_quantity: 5)
					procedure2.default_r_quantity.should eq(5)
				end

			end

		end

		describe 'default insurance quantity' do

			context "when attached to a line item" do

				it "should return the visit's insurance billing quantity if not set" do
					procedure.default_t_quantity.should eq(10)
				end

				it "should return its own quantity if set" do
					procedure.update_attributes(t_quantity: 5)
					procedure.default_t_quantity.should eq(5)
				end

			end

			context "when attached to a service" do

				it "should return zero if quantity is not set" do
					procedure2.default_t_quantity.should eq(0)
				end

				it "should return its own quantity if set" do
					procedure2.update_attributes(t_quantity: 5)
					procedure2.default_t_quantity.should eq(5)
				end

			end

		end

		describe "cost" do

			it "should return the cost when attached to a line item" do
				procedure.cost.should eq(10.0)
			end

			it "should return the cost when attached to a service" do
				procedure.cost.should eq(10.0)
			end

		end

		#TODO: This needs to be updated to account for appointment completions
		# describe "total" do

		# 	before(:each) do
  #       line_item.stub!(:applicable_rate) { 100 }
  #     end

  #     #This will be changed when appointment dates are added to each core.

  #    #  it 'should return zero if procedure is not completed' do
  #    #  	procedure.total.should eq(0.00)
  #   	# end

		# 	it "should return the correct total" do
		# 		procedure.update_attribute(:completed, true)
		# 		procedure.total.should eq(100.0)
		# 	end

		# 	it "should return new total if quantity is changed" do
		# 		procedure.update_attribute(:completed, true)
		# 		procedure.total.should eq(100.0)
		# 		procedure.update_attributes(r_quantity: 5)
		# 		procedure.total.should eq(50.0)
		# 	end
		# end
	end
end