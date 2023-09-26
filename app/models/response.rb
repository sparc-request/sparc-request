# Copyright © 2011-2022 MUSC Foundation for Research Development
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

class Response < ApplicationRecord
  audited
  
  belongs_to :survey
  belongs_to :identity
  belongs_to :respondable, polymorphic: true
  
  has_many :question_responses, dependent: :destroy
  
  accepts_nested_attributes_for :question_responses

  # set this aattribute to skip the send_additional_surveys action after create
  attr_accessor :skip_additional_surveys
  
  after_create :send_additional_surveys, if: Proc.new {|r| r.respondable_type == 'SubServiceRequest'}, unless: :skip_additional_surveys

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

  # The following is a method for generating additional recipients for a survey or form based on the intended recipient list created by the survey owner
  def generate_additional_recipients
    # Create an empty array that will hold the final identities list
    project_role_identities = []

    # First, find out if there *would* be any additional recipients based on whether this response is attatched to a protocol
    if self.respondable_id
      
      # Get the list of roles to be notified, transformed into their proper text forms
      roles = JSON.parse(self.survey.notify_roles).map{|role| PermissibleValue.find(role).key}

      # Find the protocol associated with this response
      protocol = SubServiceRequest.find(self.respondable_id).service_request.protocol


      # Only bother with the next steps if the SSR has a protocol associated with it (since, apparently, SSRs can exist without a protocol)
      if protocol.present?
        # For each role...
        roles.each do |role|
          # Get the list of project_role holders that match that specific role for the protocol...
          project_roles = protocol.project_roles.where(role: role)

          # If there are any identities associated with that project role, then...
          if project_roles.present?
            #...for each project role...
            project_roles.each do |project_role|
              # Get the project_role's identity and add to the final identities list array
              project_role_identities << project_role.identity
            end
          else
            # If there are no identities associated with this project role for this protocol, then move on to the next role
            next
          end
        end

        # If the survey settings require that we notify the requester then get the service requester
        if self.survey.notify_requester
          requester = SubServiceRequest.find(self.respondable_id).service_requester
          if requester.present?
            project_role_identities << requester
          end
        end

        # Finally, exclude the identity associated with the generating response so they don't get emailed regarding the very thing they just got done doing (assuming there are any identities in the project role identities list).
        if project_role_identities.present?
          project_role_identities.reject!{|pri| pri.id == self.identity_id}
        end
      end
    end

    # Return the final identities list as the conclusion for this method
    return project_role_identities
  end

  def send_additional_surveys
    recipients = self.generate_additional_recipients

    if recipients.present?
      recipients.each do |recipient|
        Response.create(survey: self.survey, identity: recipient, respondable_id: self.respondable_id, respondable_type: self.respondable_type, skip_additional_surveys: true)
      end

      SurveyNotification.service_survey([self.survey], recipients, self.try(:respondable)).deliver_now
    end
  end

end
