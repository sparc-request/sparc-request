require "rails_helper"

RSpec.describe Dashboard::EpicQueuesController do
  describe "GET #index" do
    before(:each) do
      @all_epic_queues = instance_double(ActiveRecord::Relation)
      allow(EpicQueue).to receive(:all).and_return(@all_epic_queues)

      logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      get :index
    end

    it "should put all EpicQueues in @epic_queues" do
      expect(assigns(:epic_queues)).to eq(@all_epic_queues)
    end

    it { is_expected.to render_template "dashboard/epic_queues/index" }
    it { is_expected.to respond_with :ok }
  end
end
