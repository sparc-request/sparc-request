require 'rails_helper'

RSpec.describe "/additional_funding_sources", type: :request, js: true do

  let!(:protocol) { create(:protocol_without_validations) }

  describe "GET /new" do
    it "renders a successful response" do
      # GET /additional_funding_sources/new?additional_funding_source[protocol_id]=64&format=js
      get new_additional_funding_sources_url, params: { additional_funding_source: { protocol_id: protocol.id }, format: :js }, xhr: true
      expect(response).to render_template(:new)
    end
  end
end
