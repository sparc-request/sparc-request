require "rails_helper"

RSpec.describe Dashboard::EpicQueuesController do
  describe "DELETE #destroy" do
    before(:each) do
      @epic_queue = build_stubbed(:epic_queue)
      allow(@epic_queue).to receive(:destroy)
      allow(EpicQueue).to receive(:find).
        with(@epic_queue.id.to_s).
        and_return(@epic_queue)
    end

    describe "for overlord users" do
      before(:each) do
        log_in_dashboard_identity(obj: build(:identity, ldap_uid: 'jug2'))
        xhr :delete, :destroy, id: @epic_queue.id
      end

      it "should delete EpicQueue from params[:id]" do
        expect(@epic_queue).to have_received(:destroy)
      end

      it { is_expected.to render_template "dashboard/epic_queues/destroy"}
      it { is_expected.to respond_with :ok }
    end

    describe "for creepy hacker doods" do 
      before(:each) do
        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :delete, :destroy, id: @epic_queue.id
      end

      it "should not delete the EpicQueue from params[:id]" do
        expect(@epic_queue).to_not have_received(:destroy)
      end

      it { is_expected.to_not render_template "dashboard/epic_queues/destroy"}
      it { is_expected.to respond_with 200 }
    end
  end
end
