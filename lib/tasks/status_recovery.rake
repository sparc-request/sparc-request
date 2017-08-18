task status_recovery: :environment do

  audits = AuditRecovery.where("auditable_id = #{10129} and auditable_type = 'SubServiceRequest' and action = 'update' and audited_changes like '%status%'")

  audits.each do |k, v|
    unless k['audited_changes']['status'][0] == nil
      PastStatus.create(sub_service_request_id: 23988, status: k['audited_changes']['status'][0], date: k['created_at'], changed_by_id: k['user_id'].to_i)
    end
  end

  approval_audits = AuditRecovery.where(auditable_type: 'Approval')
  approval_audits.each do |k, v|
    if k['audited_changes']['sub_service_request_id'].to_i == 10129
      Approval.create(sub_service_request_id: 23988, approval_date: k['audited_changes']['approval_date'],
                      approval_type: k['audited_changes']['approval_type'], identity_id: k['audited_changes']['identity_id'].to_i)
    end
  end
end