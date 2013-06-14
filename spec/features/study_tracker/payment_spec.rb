require 'spec_helper'

describe "payments", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()


  before :each do
    # create_visits
    visit study_tracker_sub_service_request_path sub_service_request.id
    click_link("Payments")
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "Entering billing information" do
    before(:each){ click_link "Add a payment" }

    context "with valid information" do
      before :each do 
        within('#payments') do
          within("tbody tr:last-child") do
            find(".date_submitted input").set("6/13/2013")
            find(".amount_invoiced input").set("500")
            find(".amount_received input").set("400")
            find(".date_received input").set("6/14/2013")
            find(".payment_method select").select("Check")
            find(".details textarea").set("Some details")
          end
          click_button("Save")
        end
      end

      it "saves the record to the database" do
        p = sub_service_request.payments.last

        p.date_submitted.should == Date.new(2013, 6, 13)
        p.amount_invoiced.should == 500.0
        p.amount_received.should == 400.0
        p.date_received.should == Date.new(2013, 6, 14)
        p.payment_method.should == "Check"
        p.details.should == "Some details"
      end

    end
  end
end