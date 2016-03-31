task :has_duplicate_line_items_visits => :environment do

  def prompt(*args)
      print(*args)
      STDIN.gets.strip
  end

  def display_protocol_status(has_duplicates, protocol_id)
    if has_duplicates
      puts "Protocol #{protocol_id} needs to be repushed to Epic"
    else
      puts "No duplicates were found for #{protocol_id}"
    end
  end

  def check_arms(arms)
    arms.each do |arm|
      livs = arm.line_items_visits.group_by(&:line_item_id)
      livs.values.each do |liv_array|
        if liv_array.size > 1
          return true
        end
      end

      return false
    end
  end

  puts "This task will determine if a given protocol needs to be repushed to Epic"
  puts "due to it having duplicate line items visits."
  continue = 'Yes'
  has_duplicates = false

  while continue == 'Yes'
    protocol_id = (prompt "Enter a protocol id to check: ").to_i
    arms = Protocol.find(protocol_id).arms
    has_duplicates = check_arms(arms)

    display_protocol_status(has_duplicates, protocol_id)
    continue = prompt "Check another protocol? (Yes/No): "
  end
end