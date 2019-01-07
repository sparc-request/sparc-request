class ConvertTablesToUtf8 < ActiveRecord::Migration[5.2]
  def up
    # SOURCE: https://gist.github.com/tjh/1711329#gistcomment-1699805

    db = ActiveRecord::Base.connection

    execute "ALTER DATABASE `#{db.current_database}` CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    db.tables.select{|table| table != "audits"}.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

      db.columns(table).each do |column|
        case column.sql_type
          when /([a-z]*)text/i
            default = (column.default.nil?) ? '' : "DEFAULT '#{column.default}'"
            null = (column.null) ? '' : 'NOT NULL'
            execute "ALTER TABLE `#{table}` MODIFY `#{column.name}` #{column.sql_type.upcase} CHARACTER SET utf8 COLLATE utf8_unicode_ci #{default} #{null};"
          when /varchar\(([0-9]+)\)/i
            sql_type = column.sql_type.upcase
            default = (column.default.nil?) ? '' : "DEFAULT '#{column.default}'"
            null = (column.null) ? '' : 'NOT NULL'
            execute "ALTER TABLE `#{table}` MODIFY `#{column.name}` #{sql_type} CHARACTER SET utf8 COLLATE utf8_unicode_ci #{default} #{null};"
        end
      end
    end
  end
end
