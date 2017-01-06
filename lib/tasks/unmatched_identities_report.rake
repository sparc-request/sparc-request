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

desc "Unmatched Identities"
# Identities that do not have a match in professional organizations table
task :unmatched_identities_report => :environment do 
  CSV.open('tmp/unmatched_identitites.csv', 'wb') do |csv|
    ### INSTITUTION, COLLEGE, DEPARTMENT ALL ARE NIL OR EMPTY ####
    identities_with_all_nil_values = Identity.all.where(professional_organization_id: nil).where(college: nil).where(department: nil).where(institution: nil)
    identities_with_all_empty_values = Identity.all.where(professional_organization_id: nil).where(college: "").where(department: "").where(institution: "")
    identitites_with_no_professional_organization_id = Identity.all.where(professional_organization_id: nil)
    unmatched_identities = ((identitites_with_no_professional_organization_id - identities_with_all_nil_values) - identities_with_all_empty_values)

    csv << ['UNMATCHED IDENTITIES']
    csv << ['Identities that do not have a match in Professional Organizations table']
    csv << ['Total unmatched entries: ', unmatched_identities.count]
    csv << ['Identity ID', 'Insitution', 'College', 'Department']
    
    unmatched_identities.each do |identity|
      csv << [identity.id, identity.institution, identity.college, identity.department]
    end

    csv << ['Identities with nil/empty for INSTITUTION, COLLEGE, AND DEPARTMENT']
    csv << ['Total nil/empty entries: ', [identities_with_all_nil_values, identities_with_all_empty_values].flatten.count]
    csv << ['Identity ID']

    [identities_with_all_nil_values, identities_with_all_empty_values].flatten.each do |identity|
      csv << [identity.id]
    end
  end
end