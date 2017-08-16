task status_recovery: :environment do

  audits = AuditRecovery.where("auditable_id = #{10129} and auditable_type = 'SubServiceRequest' and action = 'update' and audited_changes like '%status%'")

  audits.each do |k, v|
    unless k['audited_changes']['status'][0] == nil
      PastStatus.create(sub_service_request_id: 23988, status: k['audited_changes']['status'][0], date: k['created_at'], changed_by_id: k['user_id'].to_i)
    end
  end
end