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

desc "Match Identity with Professional Organization"
task :match_identity_with_professional_organization => :environment do

  #### DEPARTMENT ####
  puts "START"
  puts Identity.all.where(professional_organization_id: nil).count
  one_department_match = Hash.new
  more_than_one_department_match = Hash.new

  Identity.all.map(&:department).uniq.each do |department|
    prof_org = ProfessionalOrganization.where("LOWER(professional_organizations.name) LIKE LOWER('%#{department}%')").where(org_type: 'department')
    if !prof_org.empty?
      if prof_org.count == 1
        one_department_match[department] = prof_org.first.id
      else
        more_than_one_department_match[department] = prof_org.map(&:id)
      end
    end
  end

  one_department_match["medicine"] = 45
  one_department_match["radiology"] = 59
  one_department_match["surgery"] = 61
  one_department_match["urology"] = 62
  more_than_one_department_match.delete(nil)
  more_than_one_department_match.delete("")
  more_than_one_department_match.delete("medicine")
  more_than_one_department_match.delete("radiology")
  more_than_one_department_match.delete("surgery")
  more_than_one_department_match.delete("urology")

  one_department_match.each do |key, value|
    unassigned_identities = Identity.all.where(professional_organization_id: nil)
    identities_with_key = unassigned_identities.where(department: key)
    identities_with_key.each do |identity_with_key|
      identity_with_key.update_attribute(:professional_organization_id, value)
    end
  end

  puts "END OF DEPARTMENT"
  puts Identity.all.where(professional_organization_id: nil).count
  ### END DEPARTMENT ###

  ### COLLEGE ###
  one_college_match = Hash.new
  more_than_one_college_match = Hash.new

  Identity.all.map(&:college).uniq.each do |college|
    college_org = ProfessionalOrganization.where("LOWER(professional_organizations.name) LIKE LOWER('%#{college}%')").where(org_type: 'college')
    if !college_org.empty?
      if college_org.count == 1
        one_college_match[college] = college_org.first.id
      else
        more_than_one_college_match[college] = college_org.map(&:id)
      end
    end
  end

  one_college_match.each do |key, value|
    unassigned_identities = Identity.all.where(professional_organization_id: nil)
    identities_with_key = unassigned_identities.where(college: key)
    identities_with_key.each do |identity_with_key|
      identity_with_key.update_attribute(:professional_organization_id, value)
    end
  end
  puts "END OF COLLEGE"
  puts Identity.all.where(professional_organization_id: nil).count

  ### END COLLEGE ###

  ### INSTITUTION ###

  unassigned_identities = Identity.all.where(professional_organization_id: nil)
  identities_with_key = unassigned_identities.where(institution: 'medical_university_of_south_carolina')
  identities_with_key.each do |identity_with_key|
    identity_with_key.update_attribute(:professional_organization_id, 3)
  end
  puts "END OF INSTITUTION"
  puts Identity.all.where(professional_organization_id: nil).count

  ### END INSTITUTION ###
end