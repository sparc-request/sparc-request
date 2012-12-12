require 'spec_helper'

describe 'ServiceRequest' do

  context 'fulfillment' do

    describe 'adding and removing visits' do

      let!(:service_request) { FactoryGirl.create(:service_request, subject_count: 5, visit_count: 5) }
      let!(:service)         { FactoryGirl.create(:service) }
      let!(:service2)        { FactoryGirl.create(:service) }
      let(:line_item)        { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id) }
      let(:line_item2)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id) }

      before(:each) do
        5.times do
          FactoryGirl.create(:visit, line_item_id: line_item.id)
          FactoryGirl.create(:visit, line_item_id: line_item2.id)
        end
        @sr = ServiceRequest.first
      end

      it "should increase the visit count on the service request by one" do
        original_visit_count = @sr.visit_count
        @sr.add_visit
        @sr.visit_count.should eq(original_visit_count + 1)
      end

      it "should add a visit to the end if no position is specified" do
        @sr.add_visit
        LineItem.find(line_item.id).visits.count.should eq(6)
      end

      it "should add a visit at the specified positon" do
        last_visit = line_item.visits.last
        last_visit.update_attribute(:research_billing_qty, 99)
        @sr.add_visit(3).should eq true
        @sr.visit_count.should eq 6
        @sr.line_items[0].visits.count.should eq 6
        @sr.line_items[1].visits.count.should eq 6
        line_item.visits.where(:position => 6).first.research_billing_qty.should eq(99)
      end

      it "should fail if protocol id is nil" do
        @sr.protocol_id = nil
        @sr.save(:validate => false)

        @sr.visit_count.should eq 5
        @sr.line_items[0].visits.count.should eq 5
        @sr.line_items[1].visits.count.should eq 5

        @sr.add_visit('abcdef').should eq false

        @sr.visit_count.should eq 5
        @sr.line_items[0].visits.count.should eq 5
        @sr.line_items[1].visits.count.should eq 5
      end

      it "should decrease the visit count by one" do
        visit_count = @sr.visit_count
        @sr.remove_visit(1)
        @sr.visit_count.should eq(visit_count - 1)
      end 

      it "should remove a visit at the specified position" do
        first_visit = line_item.visits.first
        first_visit.update_attributes(billing: "your mom")
        @sr.remove_visit(1)
        new_first_visit = line_item.visits.first
        new_first_visit.billing.should_not eq("your mom")
      end
    end
  end
end
