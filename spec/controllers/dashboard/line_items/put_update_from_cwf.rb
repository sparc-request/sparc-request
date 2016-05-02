require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe "PUT #update_from_cwf" do
    before(:each) do
      logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
    end
  end
end
