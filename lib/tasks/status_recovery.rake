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

task status_recovery: :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  recovered_ssr_id = prompt('Enter the id of the sub service request that statuses are to be recovered from: ').to_i
  destination_ssr_id = prompt('Enter the id of the sub service request that the recovered statuses are to be placed under: ').to_i 

  audits = AuditRecovery.where("auditable_id = #{recovered_ssr_id} and auditable_type = 'SubServiceRequest' and action = 'update' and audited_changes like '%status%'")

  audits.each do |k, v|
    unless k['audited_changes']['status'][0] == nil
      PastStatus.create(sub_service_request_id: destination_ssr_id, status: k['audited_changes']['status'][0], date: k['created_at'], changed_by_id: k['user_id'].to_i)
    end
  end

  approval_audits = AuditRecovery.where(auditable_type: 'Approval')
  approval_audits.each do |k, v|
    if (k['audited_changes']['sub_service_request_id'].to_i == recovered_ssr_id) && (k['action'] == 'create')
      Approval.create(sub_service_request_id: destination_ssr_id, approval_date: k['audited_changes']['approval_date'],
                      approval_type: k['audited_changes']['approval_type'], identity_id: k['audited_changes']['identity_id'].to_i)
    end
  end
end