class PopulatePastStatusChangedBy < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      PastStatus.all.each do |status|
        audit = AuditRecovery.where(auditable_id: status.id).where(auditable_type: 'PastStatus').first
        unless audit.nil?
          changed_by = Identity.find(audit[:user_id])
        end
      end
    end
  end
end
