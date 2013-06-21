require 'spec_helper'

describe "payments", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()


  before :each do
    create_visits
    
    sub_service_request.update_attributes(in_work_fulfillment: true)
    visit study_tracker_sub_service_request_path(sub_service_request.id)
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
          within(".fields:last-child") do
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

      it "saves the record correctly to the database" do
        p = sub_service_request.payments.last

        p.date_submitted.should == Date.new(2013, 6, 13)
        p.amount_invoiced.should == 500.0
        p.amount_received.should == 400.0
        p.date_received.should == Date.new(2013, 6, 14)
        p.payment_method.should == "Check"
        p.details.should == "Some details"
      end

      it "takes you back to the payments tab with the new record rendered" do
        within('#payments') do
          find(".date_submitted input").should have_value("6/13/2013")
          find(".amount_invoiced input").should have_value("500.0")
          find(".amount_received input").should have_value("400.0")
          find(".date_received input").should have_value("6/14/2013")
          find(".payment_method select").should have_value("Check")
          find(".details textarea").should have_value("Some details")
        end
      end
    end

    context "with invalid information" do
      before :each do 
        within('#payments') do
          within(".fields:last-child") do
            find(".date_submitted input").set("6/13/2013")
            find(".amount_invoiced input").set("abc")
            find(".amount_received input").set("do re me")
            find(".date_received input").set("6/14/2013")
            find(".payment_method select").select("Check")
            find(".details textarea").set("Some details")
          end
          click_button("Save")
        end
      end

      it "shows the payments tab with errors on the appropriate fields" do
        within('#payments') do
          page.should have_content("amount invoiced is not a number");
          page.should have_content("amount received is not a number");
          page.should have_css(".field_with_errors")
        end
      end
    end
  end
end