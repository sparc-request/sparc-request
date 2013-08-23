require 'spec_helper'

describe "procedure" do

	let_there_be_lane
  let_there_be_j
  build_service_request_with_study
  
  before :each do
	  add_visits
	end

	context "visit schedule methods" do

		let!(:visit)             { FactoryGirl.create(:visit, research_billing_qty: 10, insurance_billing_qty: 10) }  
		let(:procedure)          { FactoryGirl.create(:procedure, visit_id: visit.id, line_item_id: line_item.id) }
		let(:procedure2)         { FactoryGirl.create(:procedure, visit_id: visit.id, service_id: service2.id) }
		let(:procedure3)         { FactoryGirl.create(:procedure, visit_id: visit.id, service_id: service2.id, line_item_id: line_item.id)}

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

		describe "total" do

			before(:each) do
        line_item.stub!(:applicable_rate) { 100 }
      end

      #This will be changed when appointment dates are added to each core.

     #  it 'should return zero if procedure is not completed' do
     #  	procedure.total.should eq(0.00)
    	# end

			it "should return the correct total" do
				procedure.update_attribute(:completed, true)
				procedure.total.should eq(100.0)
			end

			it "should return new total if quantity is changed" do
				procedure.update_attribute(:completed, true)
				procedure.total.should eq(100.0)
				procedure.update_attributes(r_quantity: 5)
				procedure.total.should eq(50.0)
			end
		end

		describe "complete indication" do

			let!(:appointment) {Appointment.create()}

			before :each do
				procedure.update_attribute(:appointment_id, appointment.id)
			end

			it "should be completed if it is checked and its appointment is completed" do
				procedure.update_attribute(:completed, true)
				appointment.update_attribute(:completed_at, Date.today)
				procedure.has_been_completed.should be_true
			end

			it "should not be completed if it is checked and its appointment is not completed" do
				procedure.update_attribute(:completed, true)
				procedure.has_been_completed.should be_false
			end

			it "should not be completed if it is unchecked and its appointment is completed" do
				appointment.update_attribute(:completed_at, Date.today)
				procedure.has_been_completed.should be_false
			end

			it "should not be completed if it is unchecked and its appointment is not completed" do
				procedure.has_been_completed.should be_false
			end

		end
	end
end