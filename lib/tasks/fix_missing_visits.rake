namespace :data do
  desc "Fix missing visits"
  task :fix_missing_visits => :environment do
    $arms_with_issues = []
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def check_arm(arm_id, all=false)
      puts ""
      arm = Arm.find arm_id.to_i
      puts "ARM: #{arm.id}"
      puts "ARM visit count: #{arm.visit_count}"
      
      vgc = arm.visit_groups.count
      puts "ARM visit group count: #{vgc}"
      
      livvcts = arm.line_items_visits.map{|liv| liv.visits.count}
      puts "ARM line items visit visits counts: #{livvcts}"
  
      unless livvcts.uniq == [vgc] 
        puts "Uh oh, missing visits"
        $arms_with_issues << arm.id
        unless all
          fix_me = prompt("Would you like to repair the data? (Yes/No) ")
          created_visits = []
    
          if fix_me == "Yes"
            ActiveRecord::Base.transaction do
              arm.line_items_visits.each do |liv|
                if liv.visits.count == vgc
                  puts "Line items visit #{liv.id} looks ok"
                else
                  print "Line items visit #{liv.id} is being repaired...."
    
                  arm.visit_groups.each do |vg|
                    vgids = liv.visits.map(&:visit_group_id)
                    next if vgids.include? vg.id  
                    
                    visit = liv.visits.create(:visit_group_id => vg.id)
                    created_visits << visit.id
                  end
                  puts "done"
                end
              end
            end # end transaction
    
            puts "Created the following visits: #{created_visits.inspect}"
          else
            puts "Ok, we'll leave it alone"
          end
        end
      end

      if not all
        again = prompt("Would you like to check another ARM? (Yes/No) ")
     
        if again == 'Yes'
          arm_id = prompt("Enter arm id: (leave blank to check all) ") 
          check_arm(arm_id)
        end
      end
    end

    arm_id = prompt("Enter arm id: (leave blank to check all) ") 

    if arm_id.to_i >= 1
      check_arm(arm_id)
    else
      Arm.all.each do |arm|
        check_arm(arm.id, true)
      end
    end

    puts ""
    puts $arms_with_issues.inspect

  end
end
