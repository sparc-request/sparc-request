require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET search_identities' do
    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))
    end

    context "search term yields at least one matching record" do
      before(:each) do
        matching_record1 = instance_double(Identity,
          display_name: "My Good Name",
          id: 1,
          email: "user1@email.com")
        matching_record2 = instance_double(Identity,
          display_name: "Person",
          id: 2,
          email: "user2@email.com")
        allow(Identity).to receive(:search).with("ABC").and_return([matching_record1, matching_record2])

        get :search_identities, term: "\n ABC \n", format: :json
      end

      it "should render those results as json" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to eq([
          { "label" => "My Good Name", "value" => 1, "email" => "user1@email.com" },
          { "label" => "Person", "value" => 2, "email" => "user2@email.com" }])
      end

      it { is_expected.to respond_with :ok }
    end

    context "search term yields no matching records" do
      before(:each) do
        allow(Identity).to receive(:search).with("ABC").and_return([])

        get :search_identities, term: "\n ABC \n", format: :json
      end

      it "should render 'No Results' in json response" do
        expect(JSON.parse(response.body)).to eq([{ "label" => "No Results" }])
      end

      it { is_expected.to respond_with :ok }
    end
  end
end
