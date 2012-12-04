require 'spec_helper'

describe "review page" do
  build_service_request_with_project

  before :each do
    add_visits
  end

  describe "clicking submit" do
    it 'Should submit the page', :js => true do
      visit review_service_request_path service_request.id
      sleep 5
    end
  end

end