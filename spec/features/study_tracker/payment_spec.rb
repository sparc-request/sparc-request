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

describe "payments", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()


  before :each do
    create_visits    
    sub_service_request.update_attributes(in_work_fulfillment: true)
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "Entering billing information" do
    before(:each) do
      visit study_tracker_sub_service_request_path(sub_service_request.id)
      click_link "Payments"
    end

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
        p.percent_subsidy.should == 50.0
        p.details.should == "Some details"
      end

      it "takes you back to the payments tab with the new record rendered" do
        within('#payments') do
          find(".date_submitted input").should have_value("6/13/2013")
          find(".amount_invoiced input").should have_value("500.00")
          find(".amount_received input").should have_value("400.00")
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

  describe "attaching a document to a payment" do
    let(:filename) {  Rails.root.join('spec', 'fixtures', 'files', 'text_document.txt') }

    before(:each) do
      sub_service_request.payments = [FactoryGirl.build(:payment)]
      sub_service_request.save!

      visit study_tracker_sub_service_request_path(sub_service_request.id)
      click_link "Payments"

      within('#payments') do
        within("td.documents") do
          click_link "Add document"
          attach_file(find('input[type="file"]')[:id], filename)
        end
        click_button("Save")
      end
    end


    it "creates a PaymentUpload with the correctly attached file" do
      sub_service_request.payments.last.uploads.first.file.original_filename.should == File.basename(filename)
    end

    it "renders a link to the attached file on subsequent page views" do
      f = sub_service_request.payments.last.uploads.first.file
      within("#payments") do
        page.should have_link(f.original_filename, href: f.url)
      end
    end

  end
end
