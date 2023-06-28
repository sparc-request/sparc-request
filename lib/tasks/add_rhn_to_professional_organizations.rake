task :add_rhn_to_professional_organizations => :environment do
  begin
    # Add top level Institution
    rhn = ProfessionalOrganization.find_or_create_by name: "Regional Health Network (RHN)"
    rhn.update(org_type: "institution")
    puts "Created or updated Institution: #{rhn.name}"

    # Add Divisions as children of Institution
    divisions_count = 0
    divisions = ["RHN-MUSC Health Florence", "RHN-MUSC Health Midlands/Columbia", "RHN-MUSC Health Lancaster", "RHN-MUSC Health Orangeburg"]
    parent_id = rhn.id
    divisions.each do |name|
      division = ProfessionalOrganization.find_or_create_by name: name
      division.update(org_type: "division", parent_id: parent_id)
      divisions_count += 1 unless division.new_record?
    end
    puts "Created or updated #{divisions_count} Divisions as children of #{rhn.name}"

    # Add Locations as children of Divisions
    florence = ["MUSC Health Florence", "MUSC Health Marion"]
    columbia = ["MUSC Health Kershaw Medical Center", "MUSC Health Columbia Medical Center", "MUSC Heart and Vascular Institute"]
    lancaster = ["MUSC Health Lancaster", "MUSC Health Chester", "MUSC Health Indian Land"]
    locations = [florence, columbia, lancaster]

    florence_id = ProfessionalOrganization.find_by(name: divisions[0]).id
    columbia_id = ProfessionalOrganization.find_by(name: divisions[1]).id
    lancaster_id = ProfessionalOrganization.find_by(name: divisions[2]).id
    parents = [florence_id, columbia_id, lancaster_id]

    locations_count = 0
    locations.each_with_index do |location, index|
      location.each do |name|
        place = ProfessionalOrganization.find_or_create_by name: name
        place.update(org_type: "location", parent_id: parents[index])
        locations_count += 1 unless place.new_record?
      end
    end
    puts "Created or updated #{locations_count} Locations as children of Divisions"
  rescue => e
    puts "Error occurred: #{e.message}"
  end
end
