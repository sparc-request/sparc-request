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
def created_line_item_audit_trail(service_request, service3, identity)
  ssr = service_request.sub_service_requests.first
  ssr.update_attribute(:submitted_at, Time.now.yesterday)
  ssr.update_attribute(:status, 'submitted')
  ssr.save!
  service_request.reload
  created_li = create(:line_item_without_validations, sub_service_request_id: ssr.id, service_id: service3.id, service_request_id: service_request.id)
  created_li_id = created_li.id
  ssr.reload
  ssr.save!
  service_request.reload

  audit2 = AuditRecovery.where("auditable_id = '#{created_li_id}' AND auditable_type = 'LineItem' AND action = 'create'")

  audit2.first.update_attribute(:created_at, Time.now - 5.hours)
  audit2.first.update_attribute(:user_id, identity.id)
end

def deleted_line_item_audit_trail(service_request, service3, identity)
  ssr = service_request.sub_service_requests.first
  ssr.update_attribute(:submitted_at, Time.now.yesterday)
  ssr.update_attribute(:status, 'submitted')
  li_id = ssr.line_items.first.id
  ssr.line_items.first.destroy!
  ssr.save!
  service_request.reload

  audit1 = AuditRecovery.where("auditable_id = '#{li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")

  audit1.first.update_attribute(:created_at, Time.now - 5.hours)
  audit1.first.update_attribute(:user_id, identity.id)
end

def deleted_and_created_line_item_audit_trail(service_request, service3, identity)
  deleted_line_item_audit_trail(service_request, service3, identity)
  created_line_item_audit_trail(service_request, service3, identity)
end

def setup_authorized_user_audit_report
  audit_report = @service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now.utc)
  audit_report = audit_report[:line_items].values.flatten
  filtered_audit_report = { :line_items => [] }
  audit_report.group_by{ |audit| audit[:audited_changes]['service_id'] }.each do |service_id, audits|
    service_actions_since_previous_submission = audits.sort_by(&:created_at).map(&:action)
    if service_actions_since_previous_submission.size >= 2 && service_actions_since_previous_submission.first == 'create' && service_actions_since_previous_submission.last == 'create'
      filtered_audit_report[:line_items] << audits.last
    elsif service_actions_since_previous_submission.size >= 2 && service_actions_since_previous_submission.first == 'create' && service_actions_since_previous_submission.last == 'destroy'
    else
      audits.each do |audit|
        filtered_audit_report[:line_items] << audit
      end
    end
  end
  filtered_audit_report[:line_items].present? ? filtered_audit_report : nil
end
