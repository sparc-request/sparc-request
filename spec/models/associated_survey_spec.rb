require 'spec_helper'

describe AssociatedSurvey do
  let!(:institution)         { FactoryGirl.create(:institution, name: 'Medical University of South Carolina', order: 1,obisid: '87d1220c5abf9f9608121672be000412',abbreviation: 'MUSC', is_available: 1)}
  let!(:provider)            { FactoryGirl.create(:provider, parent_id:institution.id,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',
                                                             obisid: '87d1220c5abf9f9608121672be0011ff',abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program)             { FactoryGirl.create(:program, type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1,obisid:'87d1220c5abf9f9608121672be021963',
                                                            abbreviation:'Informatics',process_ssrs:  0, is_available: 1)}
  let!(:core)                { FactoryGirl.create(:core, parent_id: program.id)}
  let!(:service)             { FactoryGirl.create(:service, organization_id: program.id, name: 'One Time Fee') }
  let!(:survey)              { FactoryGirl.create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil, 
                                                           data_export_identifier: nil, common_namespace: nil, common_identifier: nil, active_at: nil, inactive_at: nil, css_url: nil, 
                                                           custom_class: nil, created_at: "2013-07-02 14:40:23", updated_at: "2013-07-02 14:40:23", display_order: 0, api_id: "4137bedf-40db-43e9-a411-932a5f6d77b7", 
                                                           survey_version: 0) }

  it "should create an associated survey" do
    service.associated_surveys.create :survey_id => survey.id
    service.associated_surveys.size.should eq(1)
  end

  it "should not allow you to associate the same survey version multiple times" do
    service.associated_surveys.create :survey_id => survey.id
    service.associated_surveys.create :survey_id => survey.id

    service.reload
    service.associated_surveys.size.should eq(1)
  end

  it "should not allow you to create an associated survey without valid attributes" do

    #should not
    service.associated_surveys.create :survey_id => nil
    service.reload
    service.associated_surveys.size.should eq(0)

    AssociatedSurvey.create :surveyable_type => 'Service', :survey_id => survey.id
    AssociatedSurvey.count.should eq(0)
    
    AssociatedSurvey.create :surveyable_id => 1, :survey_id => survey.id
    AssociatedSurvey.count.should eq(0)
    
    #should for good measure
    AssociatedSurvey.create :surveyable_type => 'Service', :survey_id => survey.id, :surveyable_id => service.id
    AssociatedSurvey.count.should eq(1)
  end 
end
