require 'rails_helper'

RSpec.describe Dashboard::EpicQueueRecordsController, type: :controller do

  describe '#index' do
    it 'should have a success status' do
      log_in_dashboard_identity(obj: build(:identity, ldap_uid: 'jug2'))

      get :index, params: { format: :json }

      expect(response).to be_success
    end
  end

  describe "for creepy hacker doods" do
    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))
      get :index, params: { format: :json }
    end

    it { is_expected.to_not render_template "dashboard/epic_queues/index" }
    it { is_expected.to respond_with 200 }
  end
end

