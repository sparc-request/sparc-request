# Copyright © 2011-2016 MUSC Foundation for Research Development
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

require 'rails_helper'

RSpec.describe AssociatedSurvey do
  it "should create an associated survey" do
    service = build_stubbed(:service)
    survey = create(:survey)

    service.associated_surveys.create survey_id: survey.id

    expect(service.associated_surveys.size).to eq(1)
  end

  it "should not allow you to associate the same survey version multiple times" do
    service = create(:service)
    survey = create(:survey)

    service.associated_surveys.create survey_id: survey.id
    service.associated_surveys.create survey_id: survey.id

    service.reload
    expect(service.associated_surveys.size).to eq(1)
  end

  it "should not allow you to create an associated survey without valid attributes" do
    service = create(:service)
    survey = create(:survey)

    #should not
    service.associated_surveys.create survey_id: nil
    service.reload
    expect(service.associated_surveys.size).to eq(0)

    AssociatedSurvey.create surveyable_type: 'Service', survey_id: survey.id
    expect(AssociatedSurvey.count).to eq(0)

    AssociatedSurvey.create surveyable_id: 1, survey_id: survey.id
    expect(AssociatedSurvey.count).to eq(0)

    #should for good measure
    AssociatedSurvey.create surveyable_type: 'Service', survey_id: survey.id, surveyable_id: service.id
    expect(AssociatedSurvey.count).to eq(1)
  end
end

