require "rails_helper"

RSpec.describe Dashboard::EpicQueuesController do
  describe "DELETE #destroy" do
    before(:each) do
      @epic_queue = instance_double(EpicQueue, id: 1)
      allow(@epic_queue).to receive(:destroy)
      allow(EpicQueue).to receive(:find).with("1").and_return(@epic_queue)

      logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      xhr :delete, :destroy, id: 1
    end

    it "should delete EpicQueue from params[:id]" do
      expect(@epic_queue).to have_received(:destroy)
    end

    it { is_expected.to render_template "dashboard/epic_queues/destroy"}
    it { is_expected.to respond_with :ok }
  end
end
