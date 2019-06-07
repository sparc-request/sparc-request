# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class ChangeServiceRequestQuoteStatusToGetCostEstimate < ActiveRecord::Migration[4.2]

  class AvailableStatus < ApplicationRecord
    audited

    belongs_to :organization

    attr_accessor :new
    attr_accessor :position

    TYPES = { 'ctrc_approved': 'Active',
              'administrative_review': 'Administrative Review',
              'approved': 'Approved',
              'awaiting_pi_approval': 'Awaiting Requester Response',
              'complete': 'Complete',
              'declined': 'Declined',
              'draft': 'Draft',
              'get_a_cost_estimate': 'Get a Cost Estimate',
              'invoiced': 'Invoiced',
              'ctrc_review': 'In Admin Review',
              'committee_review': 'In Committee Review',
              'fulfillment_queue': 'In Fulfillment Queue',
              'in_process': 'In Process',
              'on_hold': 'On Hold',
              'submitted': 'Submitted',
              'withdrawn': 'Withdrawn' }
  end

  def up
    [
      'ServiceRequest',
      'SubServiceRequest',
      'PastStatus'
    ].each do |model|
      model.
        constantize.
        where(status: 'get_a_quote').
        update_all status: 'get_a_cost_estimate'
    end
    AvailableStatus.where(status: 'get_a_quote').update_all(status: 'get_a_cost_estimate')
  end

  def down
    [
      'ServiceRequest',
      'SubServiceRequest',
      'PastStatus'
    ].each do |model|
      model.
        constantize.
        where(status: 'get_a_cost_estimate').
        update_all status: 'get_a_quote'
    end
    AvailableStatus.where(status: 'get_a_quote').update_all(status: 'get_a_cost_estimate')
  end
end
