task :destroy_duplicate_line_items_visits => :environment do

  arms = Arm.joins(:protocol).where(protocols: {selected_for_epic: true})
  fixed_array = []
  arms.each do |arm|
    puts "Inspecting arm #{arm.id}"
    livs = arm.line_items_visits.order('created_at asc').group_by(&:line_item_id)
    livs.values.each do |liv_array|
      if liv_array.size > 1
        fixed_array << arm.protocol_id
      end

      liv_array.shift
      liv_array.each(&:destroy)
    end
  end

  puts 'The folowing protocols were fixed: '
  fixed_array = fixed_array.uniq
  fixed_array.each do |id|
    puts id
  end
end