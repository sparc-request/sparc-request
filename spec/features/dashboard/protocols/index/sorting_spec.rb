require 'rails_helper'

RSpec.describe 'protocol sorting', js: :true do
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

  it 'should sort protocols' do
    protocol1 = create(:study_without_validations, primary_pi: user)
    protocol2 = create(:study_without_validations, primary_pi: user)
    protocol3 = create(:study_without_validations, primary_pi: user)
    page      = visit_protocols_index_page

    page.first('.protocol-sort').click()
    wait_for_javascript_to_finish

    expect(page.search_results.protocols.first).to have_selector('td', text: protocol1.id)
    expect(page.search_results.protocols.second).to have_selector('td', text: protocol2.id)
    expect(page.search_results.protocols.third).to have_selector('td', text: protocol3.id)
  end

  it 'should have a visual cue' do
    protocol1 = create(:study_without_validations, primary_pi: user)
    page      = visit_protocols_index_page

    page.first('.protocol-sort').click()
    wait_for_javascript_to_finish

    expect(first('.protocol-sort')).to have_selector('.asc.sort-active')
  end

  it 'should alternate orders' do
    protocol1 = create(:study_without_validations, primary_pi: user)
    page      = visit_protocols_index_page

    page.first('.protocol-sort').click()
    wait_for_javascript_to_finish
    page.first('.protocol-sort').click()
    wait_for_javascript_to_finish

    expect(first('.protocol-sort')).to have_selector('.desc.sort-active')
  end
end