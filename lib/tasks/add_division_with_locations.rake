desc "Add a new division with locations to an existing institution"
task :add_division_with_locations => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  inst = ProfessionalOrganization.where org_type: 'institution'

  puts "\n --- Please select an institution to create a new division under ---"

  inst.each_with_index do |i, index|
    puts "{index + 1}. {i.name}"
  end

  selected_inst = nil

  loop do
    input = prompt("\nPlease enter the number of your choice: "
    selected_inst = input - 1

    if input.match?(/\A\d+\z/) && selected_inst.between?(0, inst.length - 1)
      break
    else
      puts "Invalid choice. Please enter a number between 1 and #{inst.length}."
    end
  end

  my_inst = inst[selected_inst]

  puts "You selected #{my_inst.name}"    

end
