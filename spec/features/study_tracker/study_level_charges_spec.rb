require 'spec_helper'

describe "study level charges", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    add_visits
    sub_service_request.update_attributes(in_work_fulfillment: true)
  end

  after :each do
    wait_for_javascript_to_finish
  end

  def save_form 
    within('p.buttons', visible: true) do
      click_button("Save")
      wait_for_javascript_to_finish
    end
  end

  def add_fulfillment
    find('.add_nested_fields', visible: true).click
    wait_for_javascript_to_finish
  end

  describe "entering fulfillment information" do

    before(:each) do
      visit study_tracker_sub_service_request_path(sub_service_request.id)
      click_link "Study Level Charges"
      add_fulfillment
    end

    it 'should successfully add a fulfillment' do
      page.should have_content('Date')
    end

    it 'should set and save the fields' do
  

      find('.fulfillment_date').set("5/1/2014")
      find('.fulfillment_quantity').set(1)
      find('.fulfillment_quantity_type').select("Sample")
      find('.fulfillment_unit_quantity').set(1)
      find('.fulfillment_unit_type').select("Aliquot")
      find('.fulfillment_notes').set("You're darn tootin'!")
 


      save_form

      otf = sub_service_request.one_time_fee_line_items.first
      fulfillment = otf.fulfillments.first
      fulfillment.date.should eq("Thu, 01 May 2014 00:00:00 EDT -04:00")
      fulfillment.quantity.should eq(1)
      fulfillment.quantity_type.should eq("Sample")
      fulfillment.unit_quantity.should eq(1)
      fulfillment.unit_type.should eq("Aliquot")
      fulfillment.notes.should eq("You're darn tootin'!")
    end

    context "validations" do

      it "should not allow the fulfillment to save if all fields are left blank" do
        save_form

        page.should have_content("Date, quantity, and unit quantity are required fields.")
      end

      it "should validate for the presence of the date" do
        find('.fulfillment_quantity').set(1)
        find('.fulfillment_unit_quantity').set(1)

        save_form

        page.should have_content("Date, quantity, and unit quantity are required fields.")
      end

      it "should validate for a quantity" do
        find('.fulfillment_date').set("5/1/2014")
        find('.fulfillment_unit_quantity').set(1)

        save_form

        page.should have_content("Date, quantity, and unit quantity are required fields.")
      end

      it "should validate for a unit quantity" do
        find('.fulfillment_date').set("5/1/2014")
        find('.fulfillment_quantity').set(1)
        
        save_form

        page.should have_content("Date, quantity, and unit quantity are required fields.")
      end

      it "should not require that the notes field is filled in" do
        find('.fulfillment_date').set("5/1/2014")
        find('.fulfillment_quantity').set(1)
        find('.fulfillment_unit_quantity').set(1)

        save_form

        page.should_not have_content("Date, quantity, and unit quantity are required fields.")
      end
    end
  end
end