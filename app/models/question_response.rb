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

class QuestionResponse < ActiveRecord::Base
  belongs_to :question
  belongs_to :response

  delegate :depender, to: :question

  validate :phone_number_format, if: Proc.new{ |qr| !qr.content.blank? && qr.question_id && qr.question.question_type == 'phone' }
  validate :email_format, if: Proc.new{ |qr| !qr.content.blank? && qr.question_id && qr.question.question_type == 'email' }
  validate :zipcode_format, if: Proc.new{ |qr| !qr.content.blank? && qr.question_id && qr.question.question_type == 'zipcode' }
  
  validates_numericality_of :content, only_integer: true, if: Proc.new{ |qr| !qr.content.blank? && qr.question_id && qr.question.question_type == 'number' }
  validates_presence_of :content, if: Proc.new{ |qr| qr.must_be_answered? }
  
  # Callbacks occur after validation. Any blank responses at this point must
  # have a depender that was not selected, therefore we don't want to save
  # a response for the particular question. Replaces old controller logic.
  before_save :remove_unanswered

  def phone_number_format
    if content.match(/\d{10}/).nil?
      errors.add(:base, I18n.t(:errors)[:question_responses][:phone_invalid])
    end
  end

  def email_format
    # Valid Formats:
    # X@X.X
    # X_X@X.X
    # X@X.X.X
    # X-X@X.X
    if content.match(Devise::email_regexp).nil?
      errors.add(:base, I18n.t(:errors)[:question_responses][:email_invalid])
    end
  end

  def zipcode_format
    # Valid Formats:
    # XXXXX
    # XXXXX-XXXX
    if content.match(/\A[0-9]{5}(?:-[0-9]{4})?\z/).nil?
      errors.add(:base, I18n.t(:errors)[:question_responses][:zipcode_invalid])
    end
  end

  def required?
    self.required
  end

  def report_content
    type    = self.question.question_type
    content = self.content

    if content.blank? || ['text', 'textarea', 'radio_button', 'likert', 'yes_no', 'email', 'date' 'number', 'zipcode', 'state', 'time' 'phone'].include?(type)
      content
    elsif ['checkbox', 'multiple_dropdown'].include?(type)
      content.tr("[]\"", "")
    elsif type == 'country'
      ISO3166::Country[content].name
    else
      ""
    end
  end

  def must_be_answered?
    self.required? && (self.depender.nil? || depender_selected?)
  end

  def depender_selected?
    self.depender && self.response.question_responses.detect{ |qr| qr.question_id == self.depender.question_id }.try(:content).try(:downcase) == self.depender.content.downcase
  end

  private

  def remove_unanswered
    return false if self.required? && self.content.blank?
  end
end
