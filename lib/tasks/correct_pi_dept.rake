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

desc "correct_pi_department"
task :correct_pi_department => :environment do
  def write(s)
    File.open("tmp/pi_department_output.txt", "a") do |f|
      f.puts s
    end
    puts s
  end

  no_department_listed = []
  dup_identities = []
  dup_departments = []
  no_identities = []
  no_departments = []
  updated_identities = []

  CSV.foreach("tmp/pi_department.csv", headers: true) do |row|
 
    identity = row[0].strip
    department = row[1]
    
    if department.blank?
       puts "No department listed for #{identity}"
       no_department_listed << identity
       next
    else
      department.strip!
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
      real_department = ProfessionalOrganization.where(name: department, org_type: 'department')
      
      if real_department.size == 0
        puts "No department found for #{department}"
        no_departments << "#{identity} : #{department}"
      elsif real_department.size > 1
        puts "Duplicate departments found for #{department}"
        dup_departments << "#{identity} : #{department}"
      else
        real_identity = real_identity.first
        next if real_identity.professional_organization

        real_department = real_department.first 

        real_identity.update_attribute(:professional_organization, real_department)
        puts "** Professional organization updated to #{department} for #{identity}"
        updated_identities << "#{identity}: #{real_identity.id}"
      end 
    end
  end

  write ""
  write "#"*50
  write "No department in column count: #{no_department_listed.size}"
  write "No identity found count: #{no_identities.size}"
  write "Duplicate identities count: #{dup_identities.size}"
  write "No department found count: #{no_departments.size}"
  write "Duplicate departments count: #{dup_departments.size}"
  write "Updated identites count: #{updated_identities.size}"
  write "#"*50

  write ""
  write "#"*50
  write "No department list in CSV"
  write no_department_listed
  write "#"*50
  
  write ""
  write "#"*50
  write "No identity found in database"
  write no_identities
  write "#"*50
  
  write ""
  write "#"*50
  write "Multiple identities found"
  write dup_identities 
  write "#"*50
  
  write ""
  write "#"*50
  write "No department found in database"
  write no_departments
  write "#"*50
  
  write ""
  write "#"*50
  write "Duplicate departments found in database"
  write dup_departments
  write "#"*50
  
  write ""
  write "#"*50
  write "Updated identites"
  write updated_identities
  write "#"*50

end
