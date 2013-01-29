require 'spec_helper'

describe "admin fulfillment tab", :js => true do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    add_visits
    visit portal_admin_sub_service_request_path(sub_service_request)
  end

  describe "ensure information is present" do

    it "should contain the user header information" do
      page.should have_content('Julia Glenn (glennj@musc.edu)')
      page.should have_content(service_request.protocol.short_title)
      page.should have_content("#{service_request.protocol.id}-")
    end

    it "should contain the sub service request information" do
      page.should have_xpath("//option[@value='draft' and @selected='selected']")
      # More data checks here (more information probably needs to be put in the mocks)
      page.should_not have_content('#service_request_owner')
      page.should have_xpath("//option[@value='#{service.id}' and @selected='selected']")
      page.find('#visit_name_4').value.should eq 'teapot'
      page.should have_xpath("//option[@value='#{service2.id}' and @selected='selected']")
    end

  end

  describe "changing attributes" do

    context "service request attributes" do
      it 'should save the service request status' do
        select 'Submitted', :from => 'sub_service_request_status'
        visit portal_admin_sub_service_request_path(sub_service_request)
        page.should have_xpath("//option[@value='submitted' and @selected='selected']")
        page.find('#sub_service_request_owner_id').value.should eq ""
      end

      it 'should save the proposed start and end date' do
        page.execute_script %Q{ $('#service_request_start_date_picker:visible').focus() }
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
        wait_for_javascript_to_finish

        page.execute_script %Q{ $('#service_request_end_date_picker:visible').focus() }
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
        wait_for_javascript_to_finish
        page.should have_content("Service request has been saved.")
        
        visit portal_admin_sub_service_request_path(sub_service_request)
        service_request.reload
        page.find('#service_request_start_date_picker').value.should eq service_request.start_date.strftime("%m/%d/%y")
        page.find('#service_request_end_date_picker').value.should eq service_request.end_date.strftime("%m/%d/%y")
      end
    end

    context "changing sub service request attributes" do
      it "should save the consult arranged and requester contacted dates" do
        page.execute_script %Q{ $('#sub_service_request_consult_arranged_date_picker:visible').focus() }
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
        wait_for_javascript_to_finish

        page.execute_script %Q{ $('#sub_service_request_requester_contacted_date_picker:visible').focus() }
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
        wait_for_javascript_to_finish
        page.should have_content("Service request has been saved.")
        
        visit portal_admin_sub_service_request_path(sub_service_request)
        sub_service_request.reload
        page.find('#sub_service_request_consult_arranged_date_picker').value.should eq sub_service_request.consult_arranged_date.strftime("%m/%d/%y")
        page.find('#sub_service_request_requester_contacted_date_picker').value.should eq sub_service_request.requester_contacted_date.strftime("%m/%d/%y")
      end

      context "subsidy information" do
        before :each do
          find('.add_subsidy_link').click
        end

        it "should be able to add a subsidy" do
          page.has_field?('subsidy_pi_contribution').should eq true
          page.has_field?('subsidy_percent_subsidy').should eq true
          page.has_selector?('#direct_cost_total').should eq true
        end

        it "should be able to remove a subsidy" do
          within '#subsidy_table' do
            find('.delete_data').click
          end
          has_link?("Add a Subsidy").should eq true
        end

        it 'should be able to edit a subsidy' do
          fill_in 'subsidy_percent_subsidy', :with => 50
          find('#subsidy_pi_contribution').click
          wait_for_javascript_to_finish
          page.should have_content "Service request has been saved."
          find('#subsidy_pi_contribution').value.should eq '775.0'
        end
      end
    end

    context "changing line item attributes" do
      context "changing quantities" do
        it 'should update the cost' do
          find("#line_item_quantity[data-line_item_id='#{line_item.id}']").set 10
          find("#line_item_units_per_quantity[data-line_item_id='#{line_item.id}']").click
          wait_for_javascript_to_finish
          find("#line_item_units_per_quantity[data-line_item_id='#{line_item.id}']").set 3
          find("#line_item_quantity[data-line_item_id='#{line_item.id}']").click
          wait_for_javascript_to_finish
          within '#one_time_fee_table' do
            has_content?('$300.00').should eq true
          end
        end
      end

      it 'should save process and complete dates' do
        page.execute_script %Q{ $('#line_item_#{line_item.id}_in_process_date_picker:visible').focus() }
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
        wait_for_javascript_to_finish

        page.execute_script %Q{ $('#line_item_#{line_item.id}_complete_date_picker:visible').focus() }
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
        wait_for_javascript_to_finish
        page.should have_content("Service request has been saved.")
      end
    end

    context "changing fulfillment attributes" do

    end

    context "changing visit attributes" do

    end

  end

  describe "notifications" do

  end

  describe "notes" do

  end

end