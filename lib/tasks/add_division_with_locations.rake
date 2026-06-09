desc "Add a new division with locations to an existing institution"
task :add_division_with_locations => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  inst = ProfessionalOrganization.where org_type: 'institution'

  puts "\n --- Please select an institution to create a new division under ---"

  inst.each_with_index do |i, index|
    puts "#{index + 1}. #{i.name}"
  end

  selected_inst = nil

  loop do
    input = prompt("\nPlease enter the number of your choice: ")
    selected_inst = input.to_i - 1

    if input.match?(/\A\d+\z/) && selected_inst.between?(0, inst.length - 1)
      break
    else
      puts "Invalid choice. Please enter a number between 1 and #{inst.length}."
    end
  end

  my_inst = inst[selected_inst]

  confirmed_name = nil

  loop do
    input = prompt("\nWhat is the name of the new division to create under the institution #{my_inst.name}?: ")

    confirm = prompt("\nAre you sure you want to create the division #{input} under the institution #{my_inst.name} (Y/N)?: ")

    if ['Y', 'y'].include? confirm
      confirmed_name = input
      break
    else
      puts "Ok, you didn't like that one."
    end
  end

  puts "Creating the division #{confirmed_name} under the institution #{my_inst.name}"

  new_division = ProfessionalOrganization.create name: confirmed_name, org_type: 'division', parent_id: my_inst.id

  puts "Done creating new division.  Time to create some locations."
 
  new_locations = []
 
  loop do
    input = prompt("\nWhat is the name of the new location to create under #{new_division.name}?: ")

    confirm = prompt("\nAre you sure you want to create the location #{input} under the #{new_division.name}? (Y/N): ")

    if ['Y', 'y'].include? confirm
      puts "Creating the location #{input} under the division #{new_division.name}"
      new_location = ProfessionalOrganization.create name: input, org_type: 'location', parent_id: new_division.id

      new_locations << new_location
 
      continue = prompt("\nWould you like to create another location? (Y/N): ")

      if ['N', 'n'].include? continue
        break
      end
    else
      puts "Ok, you didn't like that one."
    end
  end

  puts "\n --- All done, here is what we things look like ---"

  puts "Institution: #{my_inst.name}"
  puts "  Division: #{new_division.name}"
  new_locations.each do |loc|
    puts "    Location: #{loc.name}"
  end
end
