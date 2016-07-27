class PopulatePastStatusChangedBy < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      PastStatus.all.each do |status|
        audit = AuditRecovery.where(auditable_id: status.id).where(auditable_type: 'PastStatus').first
        unless audit.nil?
          changed_by = Identity.find(audit[:user_id]).full_name unless audit[:user_id].nil?
          status.update_attributes(changed_by: changed_by)
        end
      end
    end
  end
end
