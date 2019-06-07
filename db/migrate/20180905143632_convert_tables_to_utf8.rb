# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
