require 'rails_helper'

RSpec.describe 'dashboard/protocols/show', type: :view do
  let_there_be_lane

  before(:each) do
    assign(:user, jug2)
    assign(:protocol_role, instance_double('ProjectRole',
      'can_edit?' => true))
  end

  describe 'notes button' do
    context 'Protocol is a Project' do
      it 'should display a "Project Notes" button' do
        assign(:protocol, create(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Project',
          archived: false,
          title: 'Project_Title',
          short_title: 'Project_Short_Title')
        )
        assign(:protocol_type, 'Project')
        render

        expect(response).to have_selector('button', exact: 'Project Notes')
      end
    end

    context 'Protocol is a Study' do
      it 'should display a "Study Notes" button' do
        assign(:protocol, create(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Study',
          archived: false,
          title: 'Study_Title',
          short_title: 'Study_Short_Title')
        )
        assign(:protocol_type, 'Study')
        render

        expect(response).to have_selector('button', exact: 'Study Notes')
      end
    end
  end

  describe 'Protocol summary' do
    context 'Protocol is a Study' do
      before(:each) { assign(:protocol_type, 'Study') }

      it 'should be titled "Study Summary"' do
        assign(:protocol, build(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Study',
          archived: false,
          short_title: 'My Awesome Short Title')
        )
        render
        expect(response).to have_content('Study Summary')
      end

      context 'Study has potential funding source' do
        it 'should display Study ID, Title, Short Title, and potential funding source' do
          assign(:protocol, build(:protocol_federally_funded,
            :without_validations,
            primary_pi: jug2,
            type: 'Study',
            archived: false,
            title: 'My Awesome Full Title',
            short_title: 'My Awesome Short Title',
            id: 9999,
            potential_funding_source: 'federal',
            funding_source: 'college',
            funding_status: 'pending_funding')
          )
          render

          expect(response).to have_content('9999')
          expect(response).to have_content('My Awesome Full Title')
          expect(response).to have_content('My Awesome Short Title')

          expect(response).to have_content('Potential Funding Source')
          expect(response).to have_content('Federal')
        end
      end

      context 'Study has a funding source' do
        it 'should display Study ID, Title, Short Title, and potential funding source' do
          assign(:protocol, build(:protocol_federally_funded,
            :without_validations,
            primary_pi: jug2,
            type: 'Study',
            archived: false,
            title: 'My Awesome Full Title',
            short_title: 'My Awesome Short Title',
            id: 9999,
            potential_funding_source: 'federal',
            funding_source: 'college',
            funding_status: 'funded')
          )
          render

          expect(response).to have_content('9999')
          expect(response).to have_content('My Awesome Full Title')
          expect(response).to have_content('My Awesome Short Title')

          expect(response).not_to have_content('Potential Funding Source')
          expect(response).to have_content('Funding Source')
          expect(response).to have_content('College Department')
        end
      end
    end

    context 'Protocol is a Project' do
      it 'should be titled "Project Summary"' do
        assign(:protocol, build(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Project',
          archived: false,
          short_title: 'My Awesome Short Title')
        )
        assign(:protocol_type, 'Project')
        render
        expect(response).to have_content('Project Summary')
      end

      context 'Project has potential funding source' do
        it 'should display Project ID, Title, Short Title, and potential funding source' do
          assign(:protocol, build(:protocol_federally_funded,
            :without_validations,
            primary_pi: jug2,
            type: 'Project',
            archived: false,
            title: 'My Awesome Full Title',
            short_title: 'My Awesome Short Title',
            id: 9999,
            potential_funding_source: 'federal',
            funding_source: 'college',
            funding_status: 'pending_funding')
          )
          render

          expect(response).to have_content('9999')
          expect(response).to have_content('My Awesome Full Title')
          expect(response).to have_content('My Awesome Short Title')

          expect(response).to have_content('Potential Funding Source')
          expect(response).to have_content('Federal')
        end
      end

      context 'Project has a funding source' do
        it 'should display Project ID, Title, Short Title, and potential funding source' do
          assign(:protocol, build(:protocol_federally_funded,
            :without_validations,
            primary_pi: jug2,
            type: 'Project',
            archived: false,
            title: 'My Awesome Full Title',
            short_title: 'My Awesome Short Title',
            id: 9999,
            potential_funding_source: 'federal',
            funding_source: 'college',
            funding_status: 'funded')
          )
          render

          expect(response).to have_content('9999')
          expect(response).to have_content('My Awesome Full Title')
          expect(response).to have_content('My Awesome Short Title')

          expect(response).not_to have_content('Potential Funding Source')
          expect(response).to have_content('Funding Source')
          expect(response).to have_content('College Department')
        end
      end
    end
  end
end
