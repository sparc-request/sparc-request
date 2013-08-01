require 'spec_helper'

describe "procedure" do

	let_there_be_lane
  let_there_be_j
  build_service_request_with_study
  
  before :each do
	  add_visits
	end

	context "visit schedule methods" do

		# let!(:core)              { FactoryGirl.create(:core, name: 'Nursing Core') }
		# let!(:service)           { FactoryGirl.create(:service, name: 'Procedural Service', organization_id: core.id) }
		# let!(:service2)          { FactoryGirl.create(:service, name: 'Ad-Hoc Service', organization_id: core.id) }
		# let!(:service_request)   { FactoryGirl.create(:service_request) }
		# let!(:line_item)         { FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id) }
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

		describe 'default quantity' do

			it "should return the visit's research billing quantity if not set" do
				procedure.default_quantity.should eq(10)
			end

			it "should return its own quantity if set" do
				procedure.update_attributes(quantity: 5)
				procedure.default_quantity.should eq(5)
			end

		end

		describe "total" do

			before(:each) do
        line_item.stub!(:applicable_rate) { 100 }
      end

			it "should return the correct total" do
				procedure.total.should eq(10000)
			end

			it "should return new total if quantity is changed" do
				procedure.total.should eq(10000)
				procedure.update_attributes(quantity: 5)
				procedure.total.should eq(5000)
			end
		end
	end
end