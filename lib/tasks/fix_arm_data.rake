task fix_arm_data: :environment do

  arms = Arm.all
  count = 0
  bad_arms = CSV.open("tmp/bad_arms.csv", "wb")
  bad_arms << ['Arm ID', 'Protocol ID', 'Arm Visit Count', 'Actual Visit Count']
  arms.each do |arm|
    if arm.visit_count != arm.visit_groups.count
      bad_arms << ["#{arm.id}", "#{arm.protocol_id}", "#{arm.visit_count}", "#{arm.visit_groups.count}"]
      puts "Bad arm found. ID: #{arm.id}   Protocol ID: #{arm.protocol_id}"
      puts "arm.visit_count = #{arm.visit_count}   visits = #{arm.visit_groups.count}"
      arm.visit_count = arm.visit_groups.count
      arm.save(validate: false)
      count += 1
    end
  end

  puts "Count:"
  puts count
end