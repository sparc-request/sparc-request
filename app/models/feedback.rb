# Copyright © 2011-2019 MUSC Foundation for Research Development
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

if Setting.get_value("use_redcap_api")
  class Feedback
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    attr_accessor :name, :email, :date, :typeofrequest, :priority, :browser, :version, :sparc_request_id, :letters

    validates_presence_of :name, :email, :date, :typeofrequest, :priority, :sparc_request_id
    validates_format_of :email, with: Devise::email_regexp

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def persisted?
      false
    end

    def attributes
      [:name, :email, :date, :typeofrequest, :priority, :browser, :version, :sparc_request_id, :letters].map do |a|
        [a, self.send(a)]
      end.to_h
    end
  end
else
  class Feedback < ApplicationRecord
    audited

    validates_presence_of :name, :email, :message
    validates_format_of :email, with: Devise::email_regexp
  end
end

