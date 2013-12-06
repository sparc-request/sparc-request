class AuditRecovery < ActiveRecord::Base
  self.table_name = 'audits'
  serialize :audited_changes
end
