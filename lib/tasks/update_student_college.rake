# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

desc "update_student_college"
task :update_student_college => :environment do
  def write(s)
    File.open("tmp/student_college_output.txt", "a") do |f|
      f.puts s
    end
    puts s
  end

  no_college_listed = []
  dup_identities = []
  dup_colleges = []
  existing_college = []
  no_identities = []
  no_colleges = []
  no_project_role = []
  updated_identities = []

  CSV.foreach("tmp/student_college.csv", headers: true) do |row|
 
    identity = row[0].strip
    college = row[1]
    
    if college.blank?
       puts "No college listed for #{identity}"
       no_college_listed << identity
       next
    else
      college.strip!
    end

    name = identity.split(' ')
    first_name = name.first
    if name.size > 2
      last_name =  name[1] + " " + name[2]
    else
      last_name = name.last
    end

    real_identity = Identity.where(first_name: first_name, last_name: last_name)

    if real_identity.size == 0
      puts "No identity found for #{identity}"
      no_identities << identity
    elsif real_identity.size > 1
      puts "Duplicate identities found for #{identity}"
      real_identity = real_identity.where(professional_organization_id: nil)
      dup_identities << real_identity.map(&:email)
    else
      real_college = ProfessionalOrganization.where(name: college, org_type: 'college')
      
      if real_college.size == 0
        puts "No college found for #{college}"
        no_colleges << "#{identity} : #{college}"
      elsif real_college.size > 1
        puts "Duplicate colleges found for #{college}"
        dup_colleges << "#{identity} : #{college}"
      else
        real_identity = real_identity.first
        
        if real_identity.project_roles.empty?
          no_project_role << "#{identity}"
          next
        end

        if real_identity.professional_organization
          existing_college << "#{identity} : #{real_identity.professional_organization.name}"
          next 
        end

        real_college = real_college.first 

        real_identity.update_attribute(:professional_organization, real_college)
        puts "** Professional organization updated to #{college} for #{identity}"
        updated_identities << "#{identity}: #{real_identity.id}"
      end 
    end
  end

  write ""
  write "#"*50
  write "No college in column count: #{no_college_listed.size}"
  write "No identity found count: #{no_identities.size}"
  write "Duplicate identities count: #{dup_identities.size}"
  write "No college found count: #{no_colleges.size}"
  write "Duplicate colleges count: #{dup_colleges.size}"
  write "Existing college count: #{existing_college.size}"
  write "No project role count: #{no_project_role.size}"
  write "Updated identites count: #{updated_identities.size}"
  write "#"*50

  write ""
  write "#"*50
  write "No college list in CSV"
  write no_college_listed
  write "#"*50
  
  write ""
  write "#"*50
  write "No identity found in database"
  write no_identities
  write "#"*50
  
  write ""
  write "#"*50
  write "Duplicate identities found"
  write dup_identities 
  write "#"*50
  
  write ""
  write "#"*50
  write "No college found in database"
  write no_colleges
  write "#"*50
  
  write ""
  write "#"*50
  write "Duplicate colleges found in database"
  write dup_colleges
  write "#"*50
  
  write ""
  write "#"*50
  write "Existing college found in database"
  write existing_college 
  write "#"*50
  
  write ""
  write "#"*50
  write "No project role"
  write no_project_role 
  write "#"*50
  
  write ""
  write "#"*50
  write "Updated identites"
  write updated_identities
  write "#"*50

end
