require 'rails_helper'

RSpec.describe 'external_organizations/external_organization', type: :view do
  let!(:eo) { build(:external_organization) }

  it 'should render hidden fields with the given record index' do
    render 'external_organizations/external_organization', external_organization: eo, index: 0

    expect(response).to have_selector('#protocol_external_organizations_attributes_0_collaborating_org_name', visible: false)
  end
end
