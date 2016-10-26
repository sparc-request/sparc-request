# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# Check whether we want to use a separate database for the audit trail
begin 
  application_config ||= YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env]
  USE_SEPARATE_AUDIT_DATABASE = application_config['use_separate_audit_database'] rescue false
rescue
  raise "application.yml not found, see config/application.yml.example"
end

module Audited
  module Auditor
    module AuditedInstanceMethods
      def audit_trail(start_date, end_date)  
        self.audits.where("created_at between ? and ?", start_date, end_date)
      end
    end
  end

  module Adapters
    module ActiveRecord
      class Audit < ::ActiveRecord::Base
        # database connection information in database.yml should be named audit_environment (eg. audit_development)
        establish_connection("audit_#{Rails.env}") if USE_SEPARATE_AUDIT_DATABASE
      end
    end
  end
end
