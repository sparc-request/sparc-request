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

require 'digest/sha1'

class RedcapSurveyEmitter

  def initialize(feedback)
    @feedback = feedback
  end

  def send_form
    #the RedCap API token has differing fields between staging and production.
    #Due to potential data loss, we cannot change those fields on RedCap itself,
    #therefore here we are specifying different params based on Rails.env
    if Rails.env.production?
      record = {
        :letters => latest_letter_id + 1,
        :name => @feedback.name,
        :email => @feedback.email,
        :date => Date.strptime(@feedback.date[0..9], '%m/%d/%Y').strftime("%Y/%m/%d").gsub('/', '-'),
        :type => @feedback.typeofrequest,
        :priority => @feedback.priority,
        :browser => @feedback.browser,
        :version => @feedback.version,
        :sparc_request_id => @feedback.sparc_request_id
      }
    else
      record = {
        :letters => latest_letter_id + 1,
        :name => @feedback.name,
        :email => @feedback.email,
        :date => Date.strptime(@feedback.date[0..9], '%m/%d/%Y').strftime("%Y/%m/%d").gsub('/', '-'),
        :typeofrequest => @feedback.typeofrequest,
        :priority => @feedback.priority,
        :browser => @feedback.browser,
        :version => @feedback.version,
        :sparc_request_id => @feedback.sparc_request_id
      }
    end

    data = [record].to_json

    fields = {
      :token => Setting.get_value("redcap_token"),
      :content => 'record',
      :format => 'json',
      :type => 'flat',
      :data => data,
    }

    ch = Curl::Easy.http_post(
      Setting.get_value("redcap_api_url"),
      fields.collect{|k, v| Curl::PostField.content(k.to_s, v)}
    )

    ch.body_str
  end

  private

  def latest_letter_id
    fields = {
      :token => Setting.get_value("redcap_token"),
      :content => 'record',
      :format => 'json',
      :type => 'flat'
    }

    ch = Curl::Easy.http_post(
      Setting.get_value("redcap_api_url"),
      fields.collect{|k, v| Curl::PostField.content(k.to_s, v)}
    )

    to_array = JSON.parse(ch.body_str)

    to_array.last['letters'].to_i
  end
end

