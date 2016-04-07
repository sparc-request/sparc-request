require 'rails_helper'

RSpec.describe 'dashboard index', js: :true do
  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  fake_login_for_each_test("johnd")

  def visit_protocols_index_page
    page = Dashboard::Protocols::IndexPage.new
    page.load
    page
  end

  describe 'new protocol button' do
    context 'user clicks button and selects Study from dropdown' do
      it 'should navigate to the correct page' do
        page = visit_protocols_index_page

        page.search_results.new_protocol_button.click
        page.search_results.new_study_option.click

        expect(page.current_url).to end_with "/dashboard/protocols/new?protocol_type=study"
      end
    end

    context 'user clicks button and selects Project from dropdown' do
      it 'should navigate to the correct page' do
        page = visit_protocols_index_page

        page.search_results.new_protocol_button.click
        page.search_results.new_project_option.click

        expect(page.current_url).to end_with "/dashboard/protocols/new?protocol_type=project"
      end
    end
  end

  describe 'Protocols list' do
    describe 'archive button' do
      context 'archived Project' do
        scenario 'User clicks button' do
          protocol = create(:archived_project_without_validations, primary_pi: user)

          page = visit_protocols_index_page
          # show archived protocols
          page.filter_protocols.archived_checkbox.click
          page.filter_protocols.apply_filter_button.click
          expect(page.search_results).to have_protocols
          page.search_results.protocols.first.unarchive_project_button.click

          expect(page.search_results).to have_no_protocols
          expect(protocol.reload.archived).to be(false)
        end
      end

      context 'unarchived Project' do
        scenario 'User clicks button' do
          protocol = create(:unarchived_project_without_validations, primary_pi: user)

          page = visit_protocols_index_page
          page.search_results.protocols.first.archive_project_button.click

          expect(page.search_results).to have_no_protocols
          expect(protocol.reload.archived).to be(true)
        end
      end

      context 'archived Study' do
        scenario 'User clicks button' do
          protocol = create(:archived_study_without_validations, primary_pi: user)

          page = visit_protocols_index_page
          # show archived protocols
          page.filter_protocols.archived_checkbox.click
          page.filter_protocols.apply_filter_button.click
          expect(page.search_results).to have_protocols
          page.search_results.protocols.first.unarchive_study_button.click

          expect(page.search_results).to have_no_protocols
          expect(protocol.reload.archived).to be(false)
        end
      end

      context 'unarchived Study' do
        scenario 'User clicks button' do
          protocol = create(:unarchived_study_without_validations, primary_pi: user)

          page = visit_protocols_index_page
          page.search_results.protocols.first.archive_study_button.click

          expect(page.search_results).to have_no_protocols
          expect(protocol.reload.archived).to be(true)
        end
      end
    end
  end
end
