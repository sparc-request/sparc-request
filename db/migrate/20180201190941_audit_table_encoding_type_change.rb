class AuditTableEncodingTypeChange < ActiveRecord::Migration[5.1]
  def up
    execute('ALTER TABLE audits CONVERT TO CHARACTER SET utf8')
  end
end
