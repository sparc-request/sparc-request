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

class FixSubmissionEmailsData < ActiveRecord::Migration[5.2]
  def change
    SubmissionEmail.all.each do |sub_email|
      org = sub_email.organization
      next if org.process_ssrs

      if (process_ssrs_parent = org.process_ssrs_parent)
        ##process_ssrs is upstream
        unless process_ssrs_parent.submission_emails.map(&:email).include?(sub_email.email)
          process_ssrs_parent.submission_emails.create(organization_id: process_ssrs_parent.id, email: sub_email.email)
          puts "#{sub_email.email} added as submission email on Org ID: #{process_ssrs_parent.id} Name: #{process_ssrs_parent.name}"
        end
      else
        ##process_ssrs is downstream
        org.all_child_organizations.select{|x| x.process_ssrs}.each do |child_org|
          unless child_org.submission_emails.map(&:email).include?(sub_email.email)
            child_org.submission_emails.create(organization_id: child_org.id, email: sub_email.email)
            puts "#{sub_email.email} added as submission email on Org ID: #{child_org.id} Name: #{child_org.name}"
          end
        end
      end

      #destroy the bad data, even if neither scenario is true
      puts "Submission Email ID: #{sub_email.id} Email: #{sub_email.email} removed from non split/notify organization. Org ID: #{org.id} Name: #{org.name}"
      sub_email.destroy
    end
  end
end
