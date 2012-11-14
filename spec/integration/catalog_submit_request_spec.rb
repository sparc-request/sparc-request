require 'spec_helper'

feature 'as a user on catalog page' do
  #let(:user) { FactoryGirl.create(:identity) }
  let!(:identity) {FactoryGirl.create(:identity)}
  it 'Submit Request', :js => true do
    #login(user)
    visit root_path
    click_link "Office of Biomedical Informatics"
    save_and_open_page
  end

  before(:all) do
    Capybara.current_driver = :selenium
  end

  after(:all) do
    Capybara.use_default_driver
  end
end