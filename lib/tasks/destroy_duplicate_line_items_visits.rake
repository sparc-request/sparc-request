task :destroy_duplicate_line_items_visits => :environment do

  Arm.joins(:line_items_visits).each do |arm|
    puts "Inspecting arm #{arm.id}"
    livs = arm.line_items_visits.order('created_at asc').group_by(&:line_item_id)
    livs.values.each do |liv_array|
      liv_array.shift
      liv_array.each(&:destroy)
    end
  end
end