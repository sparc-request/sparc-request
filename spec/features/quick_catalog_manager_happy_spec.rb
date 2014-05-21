require 'spec_helper'
include CapybaraCatalogManager


describe 'Catalog Manager' do
  let_there_be_lane
  fake_login_for_each_test

  it 'Should create a functional catalog', :js => true do
    visit catalog_manager_root_path

    create_new_institution 'someInst'
    create_new_provider 'someProv', 'someInst'
    create_new_program 'someProg', 'someProv'
    create_new_core 'someCore', 'someProg'
    create_new_service 'someService', 'someCore', :otf => false
    create_new_service 'someService2', 'someCore', :otf => true
    visit root_path
    sleep 120
  end  
end