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

class Fulfillment < ActiveRecord::Base
  audited

  belongs_to :line_item
  has_many :notes, as: :notable, dependent: :destroy

  attr_accessible :line_item_id
  attr_accessible :timeframe
  attr_accessible :notes
  attr_accessible :time
  attr_accessible :date
  attr_accessible :quantity
  attr_accessible :unit_quantity
  attr_accessible :quantity_type
  attr_accessible :unit_type
  # attr_accessible :formatted_date

  validates :date, presence: true

  validates :time, format: { with: /\A\d+(?:\.\d{0,2})?\z/,
                             message: 'cannot be a decimal with more than two places after the decimal point. Correct format: "1.23"' },
                             numericality: { greater_than: 0,
                                             message: 'must be numerical'}

  default_scope -> { order('fulfillments.id ASC') }

  QUANTITY_TYPES = ['Min', 'Hours', 'Days', 'Each']
  CWF_QUANTITY_TYPES = ['Each', 'Sample', 'Aliquot', '3kg unit']
  UNIT_TYPES = ['N/A', 'Each', 'Sample', 'Aliquot', '3kg unit']

  def date=(date_arg)
    write_attribute(:date, Time.strptime(date_arg, "%m/%d/%Y")) if date_arg.present?
  end

  def within_date_range? start_date, end_date
    date = self.date.try(:to_date)

    if (date.nil? or start_date.nil? or end_date.nil?)
      false
    elsif (date >= start_date) && (date <= end_date)
      true
    else
      false
    end
  end

  private
end
