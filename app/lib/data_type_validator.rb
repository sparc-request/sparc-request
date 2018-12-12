# Copyright © 2011-2018 MUSC Foundation for Research Development
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
module DataTypeValidator
  require 'json'
  require 'uri'

  def is_boolean?(value)
    %w(true false).include?(value)
  end

  def is_json?(value)
    begin
      JSON.parse(value)
      true
    rescue
      false
    end
  end

  def is_email?(value)
    value.match?(/^([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+(,\s([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+)*$/)
  end

  def is_url?(value)
    value.match?(/^((ftp|http|https):\/\/)?[\w\-]+(((\.[a-zA-Z0-9]+)+(:\d+)?)|(:\d+))(\/[\w\-]+)*((\.[a-zA-Z]+)|(\/))?(\?([\w\-]+=.+(&[\w\-]+=.+)*)+)?$/)
  end

  def is_path?(value)
    value.match?(/^(\/|(\/\w+)+\/?)(\?(\w+=\w+(&\w+=\w+)*)+)?$/)
  end

  def get_type(value)
    if is_boolean?(value)
      'boolean'
    elsif is_json?(value)
      'json'
    elsif is_email?(value)
      'email'
    elsif is_url?(value)
      'url'
    elsif is_path?(value)
      'path'
    else
      'string'
    end
  end
end
