require 'spec_helper'

describe "subsidy page" do
  build_service_request_with_project

  before :each do
    visit service_subsidy_service_request_path service_request.id
    sleep 1
    sign_in
    sleep 1
  end

  describe "submitting a filled in form" do
    it 'Should record the pi contribution', :js => true do
    end
  end

end