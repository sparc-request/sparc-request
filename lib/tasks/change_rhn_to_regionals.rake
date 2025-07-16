task :change_rhn_to_regionals => :environment do
  begin
    institution = ProfessionalOrganization.find_by(name: "Regional Health Network (RHN)")
    if institution
      institution.update(name: "Regionals")
      puts "RHN institution name updated to Regionals"
    else
      abort "Can't find institution with name 'Regional Health Network (RHN)'. Aborting.."
    end

    divs_to_change_count = ProfessionalOrganization.where(parent_id: institution.id, org_type: "division").where("name like ?", "RHN-%").count
    if divs_to_change_count != 4
      abort "#{divs_to_change_count} divs found, but expected 4. Aborting.."
    end

    divs_count = 0
    divs_to_rename = {
      "RHN-MUSC Health Florence" => "MUSC Health PeeDee",
      "RHN-MUSC Health Midlands/Columbia" => "MUSC Health Midlands/Columbia",
      "RHN-MUSC Health Lancaster" => "MUSC Health Catawba",
      "RHN-MUSC Health Orangeburg" => "MUSC Health Orangeburg"
    }

    new_divs = [
      "MUSC Health Sumter",
      "MUSCP Carolina Family Care"
    ]

    puts "Attempting to update 6 divisions under #{institution.name} institution.."
    parent_id = institution.id

    divs_to_rename.each do |old_name, new_name|
      div = ProfessionalOrganization.find_by(name: old_name)
      div.update(name: new_name)
      divs_count += 1
    end

    new_divs.each do |name|
      div = ProfessionalOrganization.find_or_create_by(name: name)
      div.update(org_type: "division", parent_id: parent_id)
      divs_count += 1
    end

    if divs_count != 6
      abort "Expected 6 divisions under #{institution.name} institution, but found #{divs_count}. Aborting.."
    else
      puts "Created or updated #{divs_count} divisions under #{institution.name} institution."
    end

  rescue => e
    puts "Error occurred: #{e.message}"
  end
end
