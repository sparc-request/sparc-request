class PopulatePastStatusChangedById < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      statuses = PastStatus.where('created_at > ?', '2013-09-08')
      statuses.each do |status|
        audit = AuditRecovery.where(auditable_id: status.id).where(auditable_type: 'PastStatus').first
        unless audit.nil?
          changed_by_id = Identity.where(id: audit[:user_id]).pluck(:id).first
          status.update_attributes(changed_by_id: changed_by_id)
          puts "Updating status' changed_by_id column to identity id of #{changed_by_id}"
        end
      end
    end
  end
end
