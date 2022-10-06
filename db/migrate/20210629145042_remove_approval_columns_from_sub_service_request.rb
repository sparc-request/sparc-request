# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

class RemoveApprovalColumnsFromSubServiceRequest < ActiveRecord::Migration[5.2]
  def change

    CSV.open("tmp/ssr_approvals.csv", "wb") do |csv|
      csv << [
        'Protocol ID',
        'SSR ID',
        'SSR Status',
        'SSR Creation Date',
        'SSR Updated Date',
        'Approval Type'
      ]

      SubServiceRequest.where('nursing_nutrition_approved = ? OR lab_approved = ? OR imaging_approved = ? OR committee_approved = ?', true, true, true, true).each do |ssr|
        if(ssr.nursing_nutrition_approved? && !ssr.approvals.exists?(approval_type: 'Nursing/Nutrition Approved'))
          csv << [ssr.protocol_id,
            ssr.id,
            ssr.status,
            ssr.created_at,
            ssr.updated_at,
            'Nursing/Nutrition Approved']
        end

        if(ssr.lab_approved && !ssr.approvals.exists?(approval_type: 'Lab Approved'))
          csv << [ssr.protocol_id,
            ssr.id,
            ssr.status,
            ssr.created_at,
            ssr.updated_at,
            'Lab Approved']
        end

        if(ssr.imaging_approved && !ssr.approvals.exists?(approval_type: 'Imaging Approved'))
          csv << [ssr.protocol_id,
            ssr.id,
            ssr.status,
            ssr.created_at,
            ssr.updated_at,
            'Imaging Approved']
        end

        if(ssr.committee_approved && !ssr.approvals.exists?(approval_type: 'Committee Approved'))
          csv << [ssr.protocol_id,
            ssr.id,
            ssr.status,
            ssr.created_at,
            ssr.updated_at,
            'Committee Approved']
        end

      end

    end

    remove_column :sub_service_requests, :nursing_nutrition_approved
    remove_column :sub_service_requests, :lab_approved
    remove_column :sub_service_requests, :imaging_approved
    remove_column :sub_service_requests, :committee_approved
  end
end
