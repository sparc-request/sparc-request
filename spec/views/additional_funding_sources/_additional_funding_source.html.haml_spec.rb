require 'rails_helper'

RSpec.describe "additional_funding_sources/additional_funding_source", type: :view do
  let!(:protocol) { create(:protocol_without_validations) }
  let!(:additional_funding_source) { build(:additional_funding_source) }

  it "renders hidden fields" do
    render 'additional_funding_sources/additional_funding_source', additional_funding_source: additional_funding_source, index: 0

    hidden_fields = %w[id funding_source sponsor_name comments federal_grant_code federal_grant_serial_number federal_grant_title phs_sponsor non_phs_sponsor protocol_id]

    hidden_fields.each do |field|
      expect(response).to have_selector("#protocol_additional_funding_sources_attributes_0_#{field}", visible: false)
    end
  end
end
