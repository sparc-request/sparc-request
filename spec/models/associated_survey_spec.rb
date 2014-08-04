# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'spec_helper'

describe AssociatedSurvey do
  let!(:institution)         { FactoryGirl.create(:institution, name: 'Medical University of South Carolina', order: 1, abbreviation: 'MUSC', is_available: 1)}
  let!(:provider)            { FactoryGirl.create(:provider, parent_id:institution.id,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',
                                                             abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program)             { FactoryGirl.create(:program, type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1,
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
