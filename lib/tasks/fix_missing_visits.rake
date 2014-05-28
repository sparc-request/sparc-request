namespace :data do
  desc "Fix missing visits"
  task :fix_missing_visits => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    arm_id = prompt("Enter arm id: ") 

    arm = Arm.find arm_id.to_i
    
    vgc = arm.visit_groups.count
    puts "ARM visit group count: #{vgc}"
    
    livvcts = arm.line_items_visits.map{|liv| liv.visits.count}
    puts "ARM line items visit visits counts: #{livvcts}"

    unless livvcts.uniq == [vgc]
      puts "Uh oh, missing visits"
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
end
