require 'rails_helper'

RSpec.describe 'study summary', js: true do
  let_there_be_lane
  fake_login_for_each_test

  context 'Protocol is a project' do
    before(:each) do
      @page = Dashboard::Protocols::ShowPage.new
      @page.load(id: protocol.id)
      wait_for_javascript_to_finish
    end

    context 'Project has potential funding source' do
      let!(:protocol) do
        create(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Project',
          archived: false,
          title: 'Project_Title',
          short_title: 'Project_Short_Title',
          potential_funding_source: 'federal',
          funding_source: 'college',
          funding_status: 'pending_funding')
      end

      it 'should display Study ID, Title, Short Title, and potential funding source' do
        summary = @page.protocol_summary
        expect(summary).to have_content(protocol.id.to_s)
        expect(summary).to have_content('Project_Title')
        expect(summary).to have_content('Project_Short_Title')
        expect(summary).to have_content('Federal')
      end
    end

    context 'Project has a funding source' do
      let!(:protocol) do
        create(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Project',
          archived: false,
          title: 'Project_Title',
          short_title: 'Project_Short_Title',
          potential_funding_source: 'federal',
          funding_source: 'college',
          funding_status: 'funded')
      end

      it 'should display Study ID, Title, Short Title, and potential funding source' do
        summary = @page.protocol_summary
        expect(summary).to have_content(protocol.id.to_s)
        expect(summary).to have_content('Project_Title')
        expect(summary).to have_content('Project_Short_Title')
        expect(summary).to have_content('College Department')
      end
    end
  end

  context 'Protocol is a study' do
    before(:each) do
      @page = Dashboard::Protocols::ShowPage.new
      @page.load(id: protocol.id)
      wait_for_javascript_to_finish
    end

    context 'Study has potential funding source' do
      let!(:protocol) do
        create(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Study',
          archived: false,
          title: 'Study_Title',
          short_title: 'Study_Short_Title',
          potential_funding_source: 'federal',
          funding_source: 'college',
          funding_status: 'pending_funding')
      end

      it 'should display Study ID, Title, Short Title, and potential funding source' do
        summary = @page.protocol_summary
        expect(summary).to have_content(protocol.id.to_s)
        expect(summary).to have_content('Study_Title')
        expect(summary).to have_content('Study_Short_Title')
        expect(summary).to have_content('Federal')
      end
    end

    context 'Study has a funding source' do
      let!(:protocol) do
        create(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Study',
          archived: false,
          title: 'Study_Title',
          short_title: 'Study_Short_Title',
          potential_funding_source: 'federal',
          funding_source: 'college',
          funding_status: 'funded')
      end

      it 'should display Study ID, Title, Short Title, and potential funding source' do
        summary = @page.protocol_summary
        expect(summary).to have_content(protocol.id.to_s)
        expect(summary).to have_content('Study_Title')
        expect(summary).to have_content('Study_Short_Title')
        expect(summary).to have_content('College Department')
      end
    end
  end
end
