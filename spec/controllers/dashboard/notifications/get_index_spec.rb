require "rails_helper"

RSpec.describe Dashboard::NotificationsController do
  describe "GET #index" do
    context "params[:table] == 'inbox'" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        allow(Notification).to receive(:in_inbox_of).
          with(@logged_in_user.id, "SubServiceRequest id").
          and_return(["inbox notification1", "inbox notification1", "inbox notification2"])

        log_in_dashboard_identity(obj: @logged_in_user)
        get :index, table: "inbox", sub_service_request_id: "SubServiceRequest id"
      end

      it "should asssign @table to params[:table]" do
        expect(assigns(:table)).to eq("inbox")
      end

      it "should assign @notifications to current user's inbox (with no duplicates) restricted by SubServiceRequest" do
        expect(assigns(:notifications)).to eq(["inbox notification1", "inbox notification2"])
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/notifications/index" }
    end

    context "params[:table] != 'inbox'" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        allow(Notification).to receive(:in_sent_of).
          with(@logged_in_user.id, "SubServiceRequest id").
          and_return(["sent notification1", "sent notification1", "sent notification2"])

        log_in_dashboard_identity(obj: @logged_in_user)
        get :index, table: "not-inbox", sub_service_request_id: "SubServiceRequest id"
      end

      it "should asssign @table to params[:table]" do
        expect(assigns(:table)).to eq("not-inbox")
      end

      it "should assign @notifications to current user's inbox (with no duplicates) restricted by SubServiceRequest" do
        expect(assigns(:notifications)).to eq(["sent notification1", "sent notification2"])
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/notifications/index" }
    end
  end
end
