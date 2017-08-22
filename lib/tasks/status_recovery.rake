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