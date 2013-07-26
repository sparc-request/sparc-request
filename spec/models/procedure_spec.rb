require 'spec_helper'

describe "procedure" do

	context "visit schedule methods" do

		let!(:visit)     { FactoryGirl.create(:visit, research_billing_qty: 10) }   
		let!(:procedure) { FactoryGirl.create(:procedure, visit_id: visit.id) }

		describe 'default quantity' do

			it "should return the visit's research billing quantity if not set" do

				procedure.default_quantity.should eq(10)
			end

			it "should return its own quantity if set" do
				procedure.update_attributes(quantity: 5)
				procedure.default_quantity.should eq(5)
			end
		end
	end
end