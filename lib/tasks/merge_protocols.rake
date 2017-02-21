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

  first_protocol = get_protocol(false, 'first')
  second_protocol = get_protocol(false, 'second')

  puts first_protocol.inspect
  puts second_protocol.inspect
end