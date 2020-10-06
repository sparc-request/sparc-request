# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

namespace :data do
  desc "Fix Duplicate Satisfaction Survey Responses"
  task :fix_duplicate_responses => :environment do
    CSV.open('tmp/duplicate_survey_responses.csv', 'wb') do |csv|
      csv << ["List of Removed Survey Responses for Survey ID: 4"]

      Response.where(survey_id: 4).group_by(&:identity).each do |identity, identity_response_group|
        csv << ["User: #{identity.full_name}"]
        identity_response_group.group_by{|response| response.created_at.to_date}.each do |date, grouped_responses_by_date|

          if grouped_responses_by_date.size > 1
            csv << ["", "Date of Response Group:", date]
            response_to_keep = grouped_responses_by_date.first


            csv << ["", "Original Response ID:", "Original Response Timestamp:", "Protocol ID:", "Original Response Respondable ID:", "Original Response Content(s):"]
            csv << ["", response_to_keep.id, response_to_keep.created_at, response.respondable.try(:protocol).try(:id), response_to_keep.respondable_id, response_to_keep.question_responses.map(&:content).join(' | ')]

            grouped_responses_by_date.delete(response_to_keep)

            csv << ["", "Removed Response ID:", "Removed Response Timestamp:", "Removed Response Respondable ID:", "Removed Response Content(s):"]
            grouped_responses_by_date.each do |response|

              csv << ["", response.id, response.created_at, response.respondable.try(:protocol).try(:id), response.respondable_id, response.question_responses.map(&:content).join(' | ')]

              # if response.destroy
              #   csv << ["", response.id, response.created_at, response.respondable.try(:protocol).try(:id), response.respondable_id, response.question_responses.map(&:content).join(' | ')]
              # else
              #   csv << ["", "Error, could not remove response, ID: #{response.id}"]
              # end

            end
          end
        end
      end
    end
  end
end
