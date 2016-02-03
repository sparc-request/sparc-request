class AddRequestUuidToAudits < ActiveRecord::Migration
  # switch to separate audit database to run migration
  if USE_SEPARATE_AUDIT_DATABASE
    ActiveRecord::Base.establish_connection("audit_#{Rails.env}")
  end

  def self.up
    add_column(:audits, :request_uuid, :string) unless AuditRecovery.column_names.include?('request_uuid')
    add_index_unless_exists :audits, :request_uuid

    # switch back so we can add the schema_migration version
    if USE_SEPARATE_AUDIT_DATABASE
      ActiveRecord::Base.establish_connection("#{Rails.env}")
    end
    
    Audited::Adapters::ActiveRecord::Audit.reset_column_information
  end

  def self.down
    remove_column :audits, :request_uuid

    # switch back so we can add the schema_migration version
    if USE_SEPARATE_AUDIT_DATABASE
      ActiveRecord::Base.establish_connection("#{Rails.env}")
    end
  end

  def add_index_unless_exists(table_name, column_name, options = {})
    return false if index_exists?(table_name, column_name)
    add_index(table_name, column_name, options)
  end

  def index_exists?(table_name, column_name)
    column_names = Array(column_name)
    indexes(table_name).map(&:name).include?(index_name(table_name, column_names))
  end
end
