class AddRequestUuidToAudits < ActiveRecord::Migration
  # switch to separate audit database to run migration
  if USE_SEPARATE_AUDIT_DATABASE
    ActiveRecord::Base.establish_connection("audit_#{Rails.env}")
  end

  def self.up
    add_column :audits, :request_uuid, :string
    add_index :audits, :request_uuid
   
    # switch back so we can add the schema_migration version
    if USE_SEPARATE_AUDIT_DATABASE
      ActiveRecord::Base.establish_connection("#{Rails.env}")
    end 
  end

  def self.down
    remove_column :audits, :request_uuid
    
    # switch back so we can add the schema_migration version
    if USE_SEPARATE_AUDIT_DATABASE
      ActiveRecord::Base.establish_connection("#{Rails.env}")
    end 
  end
end
