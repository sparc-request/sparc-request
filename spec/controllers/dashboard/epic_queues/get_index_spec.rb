require "rails_helper"

RSpec.describe Dashboard::EpicQueuesController do
  describe "GET #index" do
    before(:each) do
      @all_epic_queues = instance_double(ActiveRecord::Relation)
      allow(EpicQueue).to receive(:all).and_return(@all_epic_queues)
    end

    describe "for overlord users" do
      before(:each) do
        log_in_dashboard_identity(obj: build(:identity, ldap_uid: 'jug2'))
        get :index, format: :json
      end

      it "should put all EpicQueues in @epic_queues" do
        expect(assigns(:epic_queues)).to eq(@all_epic_queues)
      end

      it { is_expected.to render_template "dashboard/epic_queues/index" }
      it { is_expected.to respond_with 200 }
    end

    describe "for creepy hacker doods" do
      before(:each) do
        log_in_dashboard_identity(obj: build_stubbed(:identity))
        get :index, format: :json
      end

      it "should put all EpicQueues in @epic_queues" do
        expect(assigns(:epic_queues)).to_not eq(@all_epic_queues)
      end

      it { is_expected.to_not render_template "dashboard/epic_queues/index" }
      it { is_expected.to respond_with 200 }
    end
  end
end
