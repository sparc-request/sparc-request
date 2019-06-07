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

desc "Task for merging two protocols"
task :protocol_merge => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_protocol(error=false, protocol_place)
    puts "It appears that was not a valid protocol id" if error
    if protocol_place == 'first'
      puts '#' * 20
      puts '#' * 20
      puts 'Enter the id of the first protocol.'
      puts 'Please note that this is the protocol that will be set as the master protocol.'
      puts 'Any attributes chosen when there are differences between the two protocols'
      puts 'will be set to this protocol.'
      id = prompt '=> '
    else
      puts 'Enter the id of the second protocol: '
      id = prompt '=> '
    end

    protocol = Protocol.where(id: id.to_i).first

    while !protocol
      protocol = get_protocol(true, protocol_place)
    end

    protocol
  end

  def get_value(error, first_value, second_value)
    puts "It appears that was not a valid number. Please enter 1 or 2" if error
    number = prompt "Enter the number of the value you would like to keep: "

    while (number != '1') && (number != '2')
      number = get_value(true, first_value, second_value)
    end

    if number == '1'
      return first_value
    else
      return second_value
    end
  end

  def resolve_conflict(attribute, first_value, second_value)
    puts "There is a conflict between the two values of this attribute: #{attribute}"
    puts "1) = #{first_value}"
    puts "2) = #{second_value}"

    get_value(false, first_value, second_value)
  end

  def check_arm_names(second_protocol_arm, first_protocol)
    first_protocol.arms.each do |first_protocol_arm|
      if first_protocol_arm.name == second_protocol_arm.name
        puts "#" * 20
        puts 'It looks like one of the arm names for the secondary protocol conflicts'
        puts 'with an arm name on the master protocol.'
        new_name = prompt('Please enter a unique name: ')
        second_protocol_arm.update_attributes(name: new_name)
      end
    end
  end

  def has_research?(protocol, research_type)
    protocol.research_types_info.try(research_type) || false
  end

  def role_should_be_assigned?(role_to_be_assigned, protocol)
    protocol.project_roles.each do |role|
      if (role.role == role_to_be_assigned.role) && (role.identity_id == role_to_be_assigned.identity_id)
        return false
      end
    end
    return true
  end

  first_protocol = get_protocol(false, 'first')
  second_protocol = get_protocol(false, 'second')

  if second_protocol.last_epic_push_time && (second_protocol.last_epic_push_status == 'complete')
    continue = prompt('The second protocol has been pushed to epic. Are you sure that you want to continue? (y/n): ')
  else
    continue = prompt('Preparing to merge these two protocols. Are you sure you want to continue? (y/n): ')
  end

  if (continue == 'y') || (continue == 'Y')

    first_protocol.attributes.each do |attribute, value|
      if (attribute != 'id') && (attribute != 'type') && (attribute != 'created_at') && (attribute != 'updated_at') && (attribute != 'deleted_at')
        second_protocol_attributes = second_protocol.attributes
        if value != second_protocol_attributes[attribute]
          resolved_value = resolve_conflict(attribute, value, second_protocol_attributes[attribute])
          first_protocol.assign_attributes(attribute.to_sym => resolved_value)
        end
      end
    end

    first_protocol.save(validate: false)

    puts "The protocol attributes have been succesfully merged. Assigning project roles to master protocol..."

    second_protocol.project_roles.each do |role|
      if role.role != 'primary-pi' && role_should_be_assigned?(role, first_protocol)
        role.update_attributes(protocol_id: first_protocol.id)
      end
    end

    puts "Project roles have been assigned, checking for and assigning research types, impact areas, and affiliations..."

    if has_research?(second_protocol, 'human_subjects') && !has_research?(first_protocol, 'human_subjects')
      second_protocol.human_subjects_info.update_attributes(protocol_id: first_protocol.id)
    elsif has_research?(second_protocol, 'vertebrate_animals') && !has_research?(first_protocol, 'vertebrate_animals')
      second_protocol.vertebrate_animals_info.update_attributes(protocol_id: first_protocol.id)
    elsif has_research?(second_protocol, 'investigational_products') && !has_research?(first_protocol, 'investigational_products')
      second_protocol.investigational_products_info.update_attributes(protocol_id: first_protocol.id)
    elsif has_research?(second_protocol, 'ip_patents') && !has_research?(first_protocol, 'ip_patents')
      second_protocol.ip_patents_info.update_attributes(protocol_id: first_protocol.id)
    end

    second_protocol.impact_areas.each do |area|
      area.protocol_id = first_protocol.id
      area.save(validate: false)
    end

    second_protocol.affiliations.each do |affiliation|
      affiliation.protocol_id = first_protocol.id
      affiliation.save(validate: false)
    end

    puts "Research types, impact areas, and affiliations have been transferred. Assigning service requests..."

    fulfillment_ssrs = []
    second_protocol.service_requests.each do |request|
      request.protocol_id = first_protocol.id
      request.save(validate: false)
      request.sub_service_requests.each do |ssr|
        ssr.update_attributes(protocol_id: first_protocol.id)
        first_protocol.next_ssr_id = (first_protocol.next_ssr_id + 1)
        first_protocol.save(validate: false)
        if ssr.in_work_fulfillment
          fulfillment_ssrs << ssr
        end
      end
    end

    puts "Service requests have been transferred. Assigning arms..."

    second_protocol.arms.each do |arm|
      check_arm_names(arm, first_protocol)
      arm.protocol_id = first_protocol.id
      arm.save(validate: false)
    end

    puts "Arms have been transferred. Assigning documents..."

    second_protocol.documents.each do |document|
      document.protocol_id = first_protocol.id
      document.save(validate: false)
    end

    puts 'Documents have been transferred. Assigning notes...'

    second_protocol.notes.each do |note|
      note.notable_id = first_protocol.id
      note.save(validate: false)
    end

    puts "Updating of child objects complete"
    second_protocol.delete

    puts "Merging service requests"
    Rake::Task["merge_srs"].invoke

    if fulfillment_ssrs.any?
      puts "#" * 50
      puts "#" * 50
      puts "#" * 50
      puts 'The following sub service requests have data in fulfillment'
      puts 'and need to be corrected: '
      fulfillment_ssrs.each do |ssr|
        puts "ID: #{ssr.id}"
      end 
    end
  else
    puts 'Exiting the task...'
  end
end