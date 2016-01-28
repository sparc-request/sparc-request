require 'rails_helper'

RSpec.describe 'dashboard index', js: :true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  # build_service_request_with_study

  describe 'table fields' do
    let!(:protocol) { create(:protocol_federally_funded, primary_pi: jug2, type: 'Study') }
    before :each do
      @page = Dashboard::Protocols::IndexPage.new
      @page.load
    end

    it 'should display short title' do
      expect(@page.protocols_list.rows.first.short_title).to eq protocol.short_title
    end

    it 'should display id' do
      expect(@page.protocols_list.rows.first.id).to eq protocol.id.to_s
    end

    it 'should display primary pis' do
      expect(@page.protocols_list.rows.first.primary_pis).to include(jug2.full_name)
    end
  end
end
