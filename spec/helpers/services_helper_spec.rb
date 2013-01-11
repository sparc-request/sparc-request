require 'spec_helper'

describe CatalogManager::ServicesHelper do
  let(:user)          { mock('User') }
  let(:form_name)     { 'form' }
  let(:institution)   { mock('Institution') }
  let(:provider)      { mock('Provider') }
  let(:program)       { mock('Program') }
  let(:core)          { mock('Provider') }

  before { user.stub!(:can_edit_entity?).and_return(true) }

  context :display_service_user_rights do
    
    it 'should return render form_name if a user has access at the institution level' do
      should_receive(:render).and_return("render #{form_name}")
      display_service_user_rights(user, form_name, institution).should eq "render #{form_name}"
    end

    it 'should return render form_name if a user has access at the provider level' do
      should_receive(:render).and_return("render #{form_name}")
      display_service_user_rights(user, form_name, provider).should eq "render #{form_name}"
    end

    it 'should return render form_name if a user has access at the program level' do
      should_receive(:render).and_return("render #{form_name}")
      display_service_user_rights(user, form_name, program).should eq "render #{form_name}"
    end

    it 'should return render form_name if a user has access at the core level' do
      should_receive(:render).and_return("render #{form_name}")
      display_service_user_rights(user, form_name, core).should eq "render #{form_name}"
    end

    it 'should return a sorry message if a user DOES NOT have access' do
      user.stub!(:can_edit_entity?).and_return(false)
      should_receive(:content_tag).with(:h1, 'Sorry, you are not allowed to access this page.').and_return('Sorry, you are not allowed to access this page.')
      should_receive(:content_tag).with(:h3, 'Please contact your system administrator.', :style => 'color:#999').and_return('Please contact your system administrator.')
      display_service_user_rights(user, form_name, institution).should eq "Sorry, you are not allowed to access this page.Please contact your system administrator."
    end
  end
end
