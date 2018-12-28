# Copyright © 2011-2018 MUSC Foundation for Research Development
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

class Question < ActiveRecord::Base

  belongs_to :section
  belongs_to :depender, class_name: 'Option'
  has_many :options, dependent: :destroy
  has_many :question_responses, dependent: :destroy

  has_many :dependents, through: :options

  delegate :survey, to: :section

  validates :content,
            :question_type,
            presence: true

  validates :required,
            :is_dependent,
            inclusion: { in: [true, false] }

  accepts_nested_attributes_for :options, allow_destroy: true
  
  before_update :update_options_based_on_question_type, if: :question_type_changed?

  def previous_questions
    self.survey.questions.select{ |q| q.id < self.id }
  end

  def is_dependent?
    self.is_dependent && self.depender_id.present?
  end
  
  private

  def update_options_based_on_question_type
    unless ['radio_button', 'likert', 'checkbox', 'dropdown', 'multiple_dropdown'].include?(self.question_type)
      self.options.destroy_all
    end

    if self.question_type == 'yes_no'
      self.options.create(content: 'Yes')
      self.options.create(content: 'No')
    end
  end
end
