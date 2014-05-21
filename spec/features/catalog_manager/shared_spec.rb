require 'spec_helper'

describe 'shared views', js: true do

  before :each do
    default_catalog_manager_setup
    click_link('Office of Biomedical Informatics')
    wait_for_javascript_to_finish
  end

  context "adding and deleting" do

    before :each do
      @program = Organization.where(abbreviation: "Informatics").first
      wait_for_javascript_to_finish
      within '#user_rights' do
        find('.legend').click
        wait_for_javascript_to_finish
      end
    end

    describe "catalog managers" do

      it "should add a new catalog manager" do
        add_identity_to_organization("new_cm")
        page.should have_content("Jason Leonard")
      end

      it "should delete a catalog manager" do
        delete_identity_from_organization("new_cm", ".cm_delete")
        page.should_not have_content("Jason Leonard")
      end
    end

    context "super users" do

      it "should add a new super user" do
        add_identity_to_organization("new_su")
        page.should have_content("Jason Leonard")
      end

      it "should delete a super user" do
        delete_identity_from_organization("new_su", ".su_delete")
        page.should_not have_content("Jason Leonard")
      end
    end

    context "service providers" do

      it "should add a new service provider" do
        add_identity_to_organization("new_sp")
        page.should have_content("Jason Leonard")
      end

      it "should delete a service provider" do
        delete_identity_from_organization("new_sp", ".sp_delete")
        page.should_not have_content("Jason Leonard")
      end
    end

    context "submission emails" do

      it "should add an email to the program" do
        sleep 2
        fill_in "new_se", with: "franzferdinand@ww1.gov"
        find('#new_se').native.send_keys(:return)
        wait_for_javascript_to_finish
        page.should have_content("franzferdinand@ww1.gov")
      end

      it "should delete an email from the program" do
        sleep 2
        fill_in "new_se", with: "franzferdinand@ww1.gov"
        find('#new_se').native.send_keys(:return)
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish
        within('.se_table') do
          find(".se_delete").click
        end
        wait_for_javascript_to_finish
        page.should_not have_content("franzferdinand@ww1.gov")
      end
    end
  end
end
