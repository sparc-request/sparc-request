require 'rails_helper'

RSpec.describe ExternalOrganization, type: :model do

  it { is_expected.to belong_to(:protocol) }

  it 'has none to begin with' do
    expect(ExternalOrganization.count).to eq 0
  end

  it 'validates name and type' do
    ExternalOrganization.create
    expect(ExternalOrganization.count).to eq 0
    ExternalOrganization.create collaborating_org_name:'Other', collaborating_org_type:'Other'
    expect(ExternalOrganization.count).to eq 1
  end

  it 
end
