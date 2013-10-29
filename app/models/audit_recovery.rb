class AuditRecovery < ActiveRecord::Base
  set_table_name 'audits'
  serialize :audited_changes
end
