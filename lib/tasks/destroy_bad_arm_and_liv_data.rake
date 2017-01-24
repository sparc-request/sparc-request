task destroy_bad_arm_and_liv_data: :environment do

  ids_of_good_arms = [256, 1072, 1086, 1208]

  puts "Destroying line item visits with nil subject counts"
  livs = LineItemsVisit.where(subject_count: nil)

  #Because arms are automatically destroyed it the last line item on them is destroyed
  #we need to make sure the arm is bad before destrying the line items visit
  livs.each do |liv|
    if (liv.arm.subject_count == nil) && (liv.arm.protocol_id == nil) && !ids_of_good_arms.include?(liv.arm.id)
      puts "Destroying line items visit with an id of #{liv.id}"
      liv.destroy 
    end
  end

  puts "Destroying arms with nil subject counts and nil protocol ids"
  arms = Arm.where(subject_count: nil, protocol_id: nil).where.not(id: ids_of_good_arms)

  arms.each do |arm|
    puts "Destroying arm with an id of #{arm.id}"
    arm.destroy
  end

  puts "Setting subject count of good arms to 1"
  good_arms = Arm.where(id: ids_of_good_arms)

  good_arms.each do |arm|
    puts "Updating arm with an id of #{arm.id}"
    arm.update_attributes(subject_count: 1)
  end
end 