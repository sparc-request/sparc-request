# Copyright © 2011-2016 MUSC Foundation for Research Development~
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
