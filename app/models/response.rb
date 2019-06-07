# Copyright © 2011-2019 MUSC Foundation for Research Development
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

class Response < ActiveRecord::Base
  audited
  
  belongs_to :survey
  belongs_to :identity
  belongs_to :respondable, polymorphic: true
  
  has_many :question_responses, dependent: :destroy
  
  accepts_nested_attributes_for :question_responses

  filterrific(
    default_filter_params: { include_incomplete: 'false' },
    available_filters: [
      :of_type,
      :with_state,
      :with_survey,
      :start_date,
      :end_date,
      :include_incomplete
    ]
  )

  scope :of_type, -> (type) {
    joins(:survey).where(surveys: { type: type })
  }

  STATE_FILTERS = [
    [I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:active], 1],
    [I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:inactive], 0]
  ]

  scope :with_state, -> (states) {
    # Note: States are 0 for inactive and 1 for active
    states.reject!(&:blank?)

    return nil if states.empty?

    joins(:survey).where(surveys: { active: states })
  }

  scope :with_survey, -> (survey_ids) {
    survey_ids.reject!(&:blank?)
    
    return nil if survey_ids.empty?

    joins(:survey).where(surveys: { id: survey_ids })
  }

  scope :start_date, -> (date) {
    return nil if date.blank?

    where("responses.updated_at >= ?", date.to_datetime)
  }

  scope :end_date, -> (date) {
    return nil if date.blank?

    where("responses.updated_at <= ?", date.to_datetime.end_of_day)
  }

  scope :include_incomplete, -> (boolean) {
    return nil if boolean == 'true'

    joins(:question_responses)
  }

  def completed?
    self.question_responses.any?
  end
end
