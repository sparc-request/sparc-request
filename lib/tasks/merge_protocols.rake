desc "Task for merging two protocols"
task :protocol_merge => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_protocol(error=false, protocol_place)
    puts "It appears that was not a valid protocol id" if error
    id = prompt "Enter the id of the #{protocol_place} protocol to be merged: "
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

  first_protocol = get_protocol(false, 'first')
  second_protocol = get_protocol(false, 'second')
  merged_protocol = Protocol.new

  continue = prompt('Preparing to merge these two protocols. Are you sure you want to continue? (y/n): ')

  if (continue == 'y') || (continue == 'Y')

    first_protocol.attributes.each do |attribute, value|
      if (attribute != 'id') && (attribute != 'type')
        second_protocol_attributes = second_protocol.attributes
        if value == second_protocol_attributes[attribute]
          merged_protocol.assign_attributes(attribute.to_sym => value)
        else
          resolved_value = resolve_conflict(attribute, value, second_protocol_attributes[attribute])
          merged_protocol.assign_attributes(attribute.to_sym => resolved_value)
        end
      end
    end
  end

  puts "Protocols have been succesfully merged. Assigning service requests to merged protocol..."
end