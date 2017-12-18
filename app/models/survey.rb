# Copyright © 2011-2017 MUSC Foundation for Research Development
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

class Survey < ApplicationRecord
  audited
  
  has_many :responses, dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :questions, through: :sections
  has_many :associated_surveys, dependent: :destroy

  belongs_to :surveyable, polymorphic: true

  validates :title,
            :access_code,
            presence: true

  validates_uniqueness_of :version, scope: [:access_code, :type]

  validates :version, numericality: { only_integer: true, greater_than: 0 }, presence: true

  accepts_nested_attributes_for :sections, allow_destroy: true

  default_scope -> {
    order(:access_code, :version)
  }

  scope :active, -> {
    where(active: true)
  }

  # Added because version could not be written as an attribute by FactoryGirl. Possible keyword issue?
  def version=(v)
    write_attribute(:version, v)
  end

  # Added because version could not be read as an attribute by FactoryGirl. Possible keyword issue?
  def version
    read_attribute(:version)
  end

  def insertion_name
    "Before #{title} (Version #{version})"
  end

  def report_title
    "#{self.title} - Version #{self.version.to_s} #{self.active ? '(Active)' : '(Inactive)'}"
  end
end
