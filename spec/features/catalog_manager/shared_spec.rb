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
    end

    describe "catalog managers" do

      it "should add a new catalog manager" do
        fill_in "new_cm", :with => "Leonard"
        wait_for_javascript_to_finish
        page.find('a', :text => "Jason Leonard (leonarjp@musc.edu)", :visible => true).click()
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish

        page.should have_content("Jason Leonard")
      end

      it "should delete a catalog manager" do
        fill_in "new_cm", :with => "Leonard"
        wait_for_javascript_to_finish
        page.find('a', :text => "Jason Leonard (leonarjp@musc.edu)", :visible => true).click()
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish

        # This overrides the javascript confirm dialog
        page.evaluate_script('window.confirm = function() { return true; }')

        find('.cm_delete').click
        wait_for_javascript_to_finish
        page.should_not have_content("Jason Leonard")
      end
    end
  end
end
