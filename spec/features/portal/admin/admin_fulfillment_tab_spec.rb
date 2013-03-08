require 'spec_helper'

describe "admin fulfillment tab", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    add_visits
    visit portal_admin_sub_service_request_path(sub_service_request)
    wait_for_javascript_to_finish
  end

  after :each do
    wait_for_javascript_to_finish
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
      page.find('#visit_name_4').should have_value 'teapot'
      page.should have_xpath("//option[@value='#{service2.id}' and @selected='selected']")
    end

  end

  describe "changing attributes" do

    context "service request attributes" do
      it 'should save the service request status' do
        select 'Submitted', :from => 'sub_service_request_status'
        visit portal_admin_sub_service_request_path(sub_service_request)
        page.should have_xpath("//option[@value='submitted' and @selected='selected']")
        page.find('#sub_service_request_owner_id').should have_value ""
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
        page.find('#service_request_start_date_picker').should have_value service_request.start_date.strftime("%m/%d/%y")
        page.find('#service_request_end_date_picker').should have_value service_request.end_date.strftime("%m/%d/%y")
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
        page.find('#sub_service_request_consult_arranged_date_picker').should have_value sub_service_request.consult_arranged_date.strftime("%m/%d/%y")
        page.find('#sub_service_request_requester_contacted_date_picker').should have_value sub_service_request.requester_contacted_date.strftime("%m/%d/%y")
      end

      context "subsidy information" do
        before :each do
          find('.add_subsidy_link').click
        end

        it "should be able to add a subsidy" do
          page.should have_field('subsidy_pi_contribution')
          page.should have_field('subsidy_percent_subsidy')
          page.should have_selector('#direct_cost_total')
        end

        it "should be able to remove a subsidy" do
          within '#subsidy_table' do
            find('.delete_data').click
          end
          page.should have_link("Add a Subsidy")
        end

        it 'should be able to edit a subsidy' do
          fill_in 'subsidy_percent_subsidy', :with => 50
          find('#subsidy_pi_contribution').click
          wait_for_javascript_to_finish
          page.should have_content "Service request has been saved."
          find('#subsidy_pi_contribution').should have_value '775.0'
        end
      end

      context "checking approvals" do
        it "should disable the approval once it has been checked" do
          find("#sub_service_request_lab_approved[data-sub_service_request_id='#{sub_service_request.id}']").click
          wait_for_javascript_to_finish
          find("#sub_service_request_lab_approved[data-sub_service_request_id='#{sub_service_request.id}']")['disabled'].should eq("true")
        end

        it "should add the approval to the approval history table" do
          find("#sub_service_request_lab_approved[data-sub_service_request_id='#{sub_service_request.id}']").click
          wait_for_javascript_to_finish
          within('#approval_history_table') do
            page.should have_content(Date.today.strftime("%m/%d/%y"))
            page.should have_content("Lab Approved")
            page.should have_content("Julia Glenn")
          end
        end

        it "should add the approvals in the proper order" do
          find("#sub_service_request_imaging_approved[data-sub_service_request_id='#{sub_service_request.id}']").click
          wait_for_javascript_to_finish
          find("#sub_service_request_src_approved[data-sub_service_request_id='#{sub_service_request.id}']").click
          wait_for_javascript_to_finish
          find("#sub_service_request_lab_approved[data-sub_service_request_id='#{sub_service_request.id}']").click
          wait_for_javascript_to_finish
          find("#sub_service_request_nursing_nutrition_approved[data-sub_service_request_id='#{sub_service_request.id}']").click
          wait_for_javascript_to_finish

          tr = all('#approval_history_table tr')

          within(tr[1]) do
            page.should have_content("Imaging Approved")
          end
          within(tr[2]) do
            page.should have_content("SRC Approved")
          end
          within(tr[3]) do
            page.should have_content("Lab Approved")
          end
          within(tr[4]) do
            page.should have_content("Nursing/Nutrition Approved")
          end
        end
      end
    end

    context "changing line item attributes" do
      context "changing quantities" do
        it 'should update the cost' do
          remove_from_dom("#line_item_#{line_item.id}_cost")
          find("#line_item_quantity[data-line_item_id='#{line_item.id}']").set "10"
          find("#line_item_units_per_quantity[data-line_item_id='#{line_item.id}']").click
          wait_for_javascript_to_finish

          increase_wait_time(25) do
            find("#line_item_#{line_item.id}_cost").should have_exact_text("$100.00") # TODO: this test fails a lot
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
      before :each do
        find("td.expand_li[data-line_item_id='#{line_item.id}']").click
        wait_for_javascript_to_finish
      end

      it 'should be able to add a fulfillment' do
        page.should have_link 'Add a Fulfillment'
        click_link 'Add a Fulfillment'
        wait_for_javascript_to_finish
        line_item.reload
        page.should have_field("fulfillment_#{line_item.fulfillments[0].id}_date_picker")
        page.should have_field("fulfillment_notes")
        page.should have_field("fulfillment_time")
      end

      it 'should be able to edit a fulfillment' do
        click_link 'Add a Fulfillment'
        wait_for_javascript_to_finish
        line_item.reload
        page.execute_script %Q{ $('#fulfillment_#{line_item.fulfillments[0].id}_date_picker:visible').focus() }
        page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
        page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
        wait_for_javascript_to_finish

        notes = "And Shepherds we shall be\nFor thee, my Lord, for thee.\nPower hath descended forth from Thy hand\nOur feet may swiftly carry out Thy commands.\nSo we shall flow a river forth to Thee\nAnd teeming with souls shall it ever be.\nIn Nomeni Patri Et Fili Spiritus Sancti."
        fill_in 'fulfillment_notes', :with => notes
        page.should have_content "Service request has been saved."
      end

      it 'should be able to remove a fulfillment' do
        click_link 'Add a Fulfillment'
        wait_for_javascript_to_finish
        find(".delete_data[data-fulfillment_id]").click
        wait_for_javascript_to_finish
        line_item.reload
        line_item.fulfillments.empty?.should eq true
      end
    end

    context "changing visit attributes" do
      it 'should update visit names' do
        fill_in 'visit_name_1', :with => "HOLYCOW"
        find('#visit_name_2').click
        wait_for_javascript_to_finish
        line_item2.visits[0].name.should eq "HOLYCOW"
      end

      it "should add visits" do
        click_link 'Add a Visit'
        wait_for_javascript_to_finish
        page.should have_content "Service request has been saved."
        page.should have_content 'Add Visit 12'
      end

      it 'should remove visits' do
        click_link 'Delete a Visit'
        wait_for_javascript_to_finish
        page.should have_content 'Service request has been saved.'
        page.should_not have_content 'Delete Visit 10'
      end
    end
  end

  describe "notes" do
    before :each do
      @notes = "And Shepherds we shall be For thee, my Lord, for thee. Power hath descended forth from Thy hand Our feet may swiftly carry out Thy commands. So we shall flow a river forth to Thee And teeming with souls shall it ever be."
      find('.note_box', :visible => true).set @notes
      click_link 'Add Note'
      wait_for_javascript_to_finish
    end

    it 'should add notes' do
      # TODO: This test inconsistently fails on Jenkins, possibly due to
      # Add Note taking too long.
      increase_wait_time(30) do
        within '.note_body' do
          page.should have_content @notes
        end
      end
    end

    it 'should record who posted the note and the date' do
      increase_wait_time(30) do
        within '.note_date' do
          page.should have_content Date.today.strftime("%m/%d/%y")
        end

        within '.note_name' do
          page.should have_content "#{jug2.first_name} #{jug2.last_name}"
        end
      end
    end
  end

end
