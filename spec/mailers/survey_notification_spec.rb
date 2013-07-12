require "spec_helper"

describe SurveyNotification do
  let(:identity)            { FactoryGirl.create(:identity, :email => 'nobody@nowhere.com') } 
  let(:survey)              { FactoryGirl.create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil, 
                                                         data_export_identifier: nil, common_namespace: nil, common_identifier: nil, active_at: nil, inactive_at: nil, css_url: nil, 
                                                         custom_class: nil, created_at: "2013-07-02 14:40:23", updated_at: "2013-07-02 14:40:23", display_order: 0, api_id: "4137bedf-40db-43e9-a411-932a5f6d77b7", 
                                                         survey_version: 0) }
  let(:response_set)        { mock_model(ResponseSet, :user_id => identity.id, :survey_id => survey.id, :access_code => 'abc123', :survey => survey) }

  describe 'system satisfaction survey' do
    let(:mail) { SurveyNotification.system_satisfaction_survey(response_set) }
    
    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == '[Test - EMAIL TO success@musc.edu AND CC TO amcates@gmail.com, catesa@musc.edu] System satisfaction survey completed in SPARC Request'
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.from.should == ['nobody@nowhere.com'] # set in application.yml as the default_mail_to
    end
 
    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.to.should == [identity.email]
    end
 
    #ensure that the e-mail body is correct
    it 'contains survey name' do
      mail.body.encoded.should include("#{identity.display_name}\r\nhas completed a system satisfaction survey.\r\nResults can be found\r\n<a href=\"http://localhost:3000/surveys/system-satisfaction-survey/abc123\">here</a>\r\n")
    end
  end

  describe 'service satisfaction survey' do
    include ApplicationHelper 
    let(:institution) { FactoryGirl.create(:institution) }
    let(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
    let(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
    let(:core)    { FactoryGirl.create(:core, parent_id: program.id) }
    let(:ssr)     { FactoryGirl.create(:sub_service_request, organization_id: core.id) }
    let(:mail)    { SurveyNotification.service_survey([survey], identity, ssr) }

    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == '[Test - EMAIL TO success@musc.edu AND CC TO amcates@gmail.com, catesa@musc.edu] SPARC Request Survey Notification'
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.to.should == [identity.email]
    end
 
    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['no-reply@musc.edu']
    end
 
    #ensure that the e-mail body is correct
    it 'contains survey name' do
      mail.body.encoded.should include("Dear #{identity.full_name},\r\n<br>\r\n<br>\r\nThank you for requesting services from\r\n#{ssr_institution(institution)} - #{ssr_provider(provider)} - #{ssr_program_core(core)}.\r\nThe service(s) you requested have now been completed.\r\n<br>\r\nPlease click on the link(s) below to complete the following survey(s) regarding the service(s) you received. Your feedback is important and appreciated!\r\n<br>\r\n<br>\r\n<ul></ul>\r\n<li><a href=\"http://localhost:3000/direct_link_to/system-satisfaction-survey?survey_version=0\">System Satisfaction survey</a></li>\r\n")
    end
  end
end
