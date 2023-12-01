require "rails_helper"

RSpec.describe AdditionalFundingSourcesController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/additional_funding_sources/new").to route_to("additional_funding_sources#new")
    end

    it "routes to #edit" do
      expect(get: "/additional_funding_sources/edit?id=1").to route_to("additional_funding_sources#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/additional_funding_sources").to route_to("additional_funding_sources#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/additional_funding_sources?index=1").to route_to("additional_funding_sources#update", index: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/additional_funding_sources?index=1").to route_to("additional_funding_sources#update", index: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/additional_funding_sources?index=1").to route_to("additional_funding_sources#destroy", index: "1")
    end
  end
end
