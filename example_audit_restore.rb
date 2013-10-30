# using a action, user_id, and date range
audits = AuditRecovery.where('action = "destroy" and user_id = 3597 and created_at between "2013-10-28 16:45:05" and "2013-10-28 16:45:07"')
# using exact audit ids
audits = AuditRecovery.where(:id => [65736, 65744, 65745, 65746, 65747])

audits.each do |audit|
  changes = audit.audited_changes
  changes["id"] = audit.auditable_id
  obj = audit.auditable_type.constantize

  rec = obj.new(changes, :without_protection => true) # we want to assign all attributes listed in the audit

  rec.without_auditing do # we don't want to audit the fact that we are restoring these records
   rec.save
  end
end
