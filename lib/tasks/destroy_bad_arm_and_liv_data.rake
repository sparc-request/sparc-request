task destroy_bad_arm_and_liv_data: :environment do

  ids_of_good_arms = [257, 1072, 1086, 1208, 1628, 14948]

  puts "Destroying line item visits with nil subject counts"
  livs = LineItemsVisit.where(subject_count: nil)

  #Because arms are automatically destroyed if the last line item on them is destroyed
  #we need to make sure the arm is bad before destrying the line items visit
  liv_count = 0
  livs.each do |liv|
    if (liv.arm.subject_count == nil) && (liv.arm.protocol_id == nil) && !ids_of_good_arms.include?(liv.arm.id)
      puts "Destroying line items visit with an id of #{liv.id}"
      liv.destroy 
      liv_count += 1
    end
  end

  puts "Destroying arms with nil subject counts and nil protocol ids"
  arms = Arm.where(subject_count: nil, protocol_id: nil).where.not(id: ids_of_good_arms)

  arm_count = 0
  arms.each do |arm|
    puts "Destroying arm with an id of #{arm.id}"
    arm.destroy
    arm_count += 1
  end

  puts "Setting subject count of good arms to 1"
  good_arms = Arm.where(id: ids_of_good_arms)

  good_arms.each do |arm|
    puts "Updating arm with an id of #{arm.id}"
    arm.update_attributes(subject_count: 1)
  end

  puts ""
  puts ""
  puts "Destroyed #{liv_count} line items visits and #{arm_count} arms." 
end 