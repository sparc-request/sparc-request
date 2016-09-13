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

namespace :data do
  desc "Import identities (only) from CSV"
  task :import_identities_only, [:uid_domain] => :environment do |t, args|
    if args[:uid_domain]
        CSV.foreach("identities.csv", :headers => true) do |row|
          # uid, first name, last name, email, institution, department, college  
          if row[0] and row[1] and row[2] and row[3]
            uid = row[0] << args[:uid_domain]
            identity = Identity.where(:ldap_uid => uid).first
            if identity
              identity.update_attributes(first_name: row[1], last_name: row[2], email: row[3], institution: row[4], department: row[5], college: row[6]) 
              puts "updated " + uid 
            else
              identity = Identity.create :ldap_uid => uid, :first_name => row[1], :last_name => row[2], :email => row[3], 
                                          :institution => row[4], :department => row[5], :college => row[6],
                                          :password => Devise.friendly_token[0,20], :approved => true
              puts "imported " + uid
            end
          else
            if row[0]
              puts "Error: " + row[0] + " not imported because missing data"
            else 
              puts "Error: uid not specified"
            end            
          end
        end
    else
      puts "Error UID domain must be passed in as an argument"
    end    
  end
end

