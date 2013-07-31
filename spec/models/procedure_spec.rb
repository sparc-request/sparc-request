require 'spec_helper'

describe "procedure" do

	let_there_be_lane
  let_there_be_j
  build_service_request_with_study

	context "visit schedule methods" do

		let!(:visit)     { FactoryGirl.create(:visit, research_billing_qty: 10) }   
		let!(:procedure) { FactoryGirl.create(:procedure, visit_id: visit.id, line_item_id: line_item.id) }

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