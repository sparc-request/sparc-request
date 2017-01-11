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
  puts "Already matched Identities:"
  Identity.all.where.not(professional_organization_id: nil).map(&:id)
  puts "Number of Unmatched Identities:"
  puts Identity.all.where(professional_organization_id: nil).count

  one_department_match = Hash.new
  more_than_one_department_match = Hash.new

  identity_departments = Identity.all.map(&:department).uniq

  # Remove nil and empty
  identity_departments.delete(nil)
  identity_departments.delete("")

  # Task: to match Identity to Professional Organization.
  # There was not a concrete map on how to do this.
  # Match was based on partial word equality.
  # First matched the departments (the lowest level), 
  # then matched at the college level,
  # finally matched at the institution level
  @departments_that_need_review = []
  identity_departments.each do |department|
    prof_org = ProfessionalOrganization.where("LOWER(professional_organizations.name) LIKE LOWER('%#{department}%')").where(org_type: 'department')
    if !prof_org.empty?
      if prof_org.count == 1
        one_department_match[department] = prof_org.first.id
      else
        more_than_one_department_match[department] = prof_org.map(&:id)
      end
    else
      @departments_that_need_review << department
    end
  end

  # @departments_that_need_review are departments with no partial word matches.
  # These were reviewed with Wenjun and she supplied the match for 
  # "pharmaceutical_and_biomedical_sciences", "orthopaedic_surgery", "pharmacy_and_clinical_sciences", "cell_biology_and_anatomy", "craniofacial_biology"

  @departments_that_need_review.delete("pharmaceutical_and_biomedical_sciences") ## Addressed, further down
  @departments_that_need_review.delete("orthopaedic_surgery")
  @departments_that_need_review.delete("pharmacy_and_clinical_sciences")
  @departments_that_need_review.delete("cell_biology_and_anatomy")
  @departments_that_need_review.delete("craniofacial_biology")

  # These are the remaining departments that do not have matches.
  # Wenjun decided that in these cases, we match the college, and if the
  # college doesn't match either, we match to the institution 
  puts "DEPARTMENTS THAT NEED REVIEW: "
  puts @departments_that_need_review.inspect

  one_department_match["orthopaedic_surgery"] = 52
  one_department_match["pharmacy_and_clinical_sciences"] = 122
  one_department_match["cell_biology_and_anatomy"] = 60
  one_department_match["craniofacial_biology"] = 11

  one_department_match["medicine"] = 45
  one_department_match["radiology"] = 59
  one_department_match["surgery"] = 61
  one_department_match["urology"] = 62

  # the departments with more than one department match were sorted through
  # and hard coded for appropriate match ("medicine", "radiology", "surgery", "urology") 
  # the other departments with more than one match truly had two matches
  #("biochemistry_and_molecular_biology", "cell_and_molecular_pharmacology",
  # "pathology_and_laboratory_medicine", "microbiology_and_immunology", and "pharmaceutical_and_biomedical_sciences").  The departments with two matches are addressed
  # further down around ln 187
  more_than_one_department_match.delete(nil)
  more_than_one_department_match.delete("")
  more_than_one_department_match.delete("medicine")
  more_than_one_department_match.delete("radiology")
  more_than_one_department_match.delete("surgery")
  more_than_one_department_match.delete("urology")

  # Update Identities and their professional_organization_ids according to department
  one_department_match.each do |key, value|
    unassigned_identities = Identity.all.where(professional_organization_id: nil)
    identities_with_key = unassigned_identities.where(department: key)
    identities_with_key.each do |identity_with_key|
      identity_with_key.update_attribute(:professional_organization_id, value)
    end
  end

  # There are departments with the same name, but under different colleges.  In this case, 
  # the Identity is matched based on the college, but retains the department ID
  matching_department_and_college = { "biochemistry_and_molecular_biology" => ['graduate' => 16, 'medicine' => 40], "cell_and_molecular_pharmacology" => ['graduate' => 18, 'medicine' => 41],  "pathology_and_laboratory_medicine" => ['graduate' => 26, 'medicine' => 54], "microbiology_and_immunology" => ['graduate' => 23, 'medicine' => 46], "pharmaceutical_and_biomedical_sciences" => ['graduate' => 22, 'pharmacy' => 123]}

  # Update Identities and their professional_organization_ids according to department and college
  @identities_that_need_discussion = []
  matching_department_and_college.each do |key, value|
    unassigned_identities = Identity.all.where(professional_organization_id: nil)
    identities_with_key = unassigned_identities.where(department: "#{key}")

    identities_with_key.each do |identity_with_key|
      if identity_with_key.college == 'college_of_graduate_studies'
        identity_with_key.update_attribute(:professional_organization_id, value.first['graduate'])
      elsif identity_with_key.college == 'college_of_medicine'
        identity_with_key.update_attribute(:professional_organization_id, value.first['medicine'])
      elsif identity_with_key.college == 'college_of_pharmacy'
        identity_with_key.update_attribute(:professional_organization_id, value.first['pharmacy'])
      else
        # These identities need to be added to the unmatched report
        @identities_that_need_discussion << identity_with_key
      end
    end
  end

  puts "END OF DEPARTMENT"
  puts "Number of Unmatched Identities:"
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

  # Colleges were much easier to match then department and there were no more_than_one_college_match
  # Update Identities and their professional_organization_ids according to college
  one_college_match.each do |key, value|
    unassigned_identities = Identity.all.where(professional_organization_id: nil)
    identities_with_key = unassigned_identities.where(college: key) - @identities_that_need_discussion
    identities_with_key.each do |identity_with_key|
      identity_with_key.update_attribute(:professional_organization_id, value)
    end
  end
  puts "END OF COLLEGE"
  puts "Number of Unmatched Identities:"
  puts Identity.all.where(professional_organization_id: nil).count

  ### END COLLEGE ###

  ### INSTITUTION ###

  unassigned_identities = Identity.all.where(professional_organization_id: nil)
  identities_with_key = unassigned_identities.where(institution: 'medical_university_of_south_carolina') - @identities_that_need_discussion
  # The only institution that matched with Professional Organization Institutions was 'medical_university_of_south_carolina'
  # Update Identities and their professional_organization_ids according to 'medical_university_of_south_carolina'
  identities_with_key.each do |identity_with_key|
    identity_with_key.update_attribute(:professional_organization_id, 3)
  end
  puts "END OF INSTITUTION"
  puts "Number of Unmatched Identities:"
  puts Identity.all.where(professional_organization_id: nil).count

  ### END INSTITUTION ###

  #### WENJUN MANUAL MATCHING ###
  Identity.find(8045).update_attribute(:professional_organization_id, 4)
  Identity.find(44254).update_attribute(:professional_organization_id, 4)

  Identity.find(46501).update_attribute(:professional_organization_id, 16)
  Identity.find(21330).update_attribute(:professional_organization_id, 18)

  Identity.find(4958).update_attribute(:professional_organization_id, 23)
  Identity.find(23505).update_attribute(:professional_organization_id, 23)

  Identity.find(7787).update_attribute(:professional_organization_id, 26)
  ### END WENJUN MANUAL MATCHING ###

  ### CLEARING UNMATCHED IDENTITIES PER WENJUN ###
  identities_with_all_nil_values = Identity.all.where(professional_organization_id: nil).where(college: nil).where(department: nil).where(institution: nil)
  identities_with_all_empty_values = Identity.all.where(professional_organization_id: nil).where(college: "").where(department: "").where(institution: "")
  identitites_with_no_professional_organization_id = Identity.all.where(professional_organization_id: nil)
  unmatched_identities = ((identitites_with_no_professional_organization_id - identities_with_all_nil_values) - identities_with_all_empty_values)

  unmatched_identities.each do |unmatched_identity|
    Identity.find(unmatched_identity.id).update_attribute(:institution, nil)
    Identity.find(unmatched_identity.id).update_attribute(:college, nil)
    Identity.find(unmatched_identity.id).update_attribute(:department, nil)
  end

  ### END CLEARING UNMATCHED IDENTITIES PER WENJUN ###
end