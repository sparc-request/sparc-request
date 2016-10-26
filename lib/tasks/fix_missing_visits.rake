# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

namespace :data do
  desc "Fix missing visits"
  task :fix_missing_visits => :environment do
    $arms_with_issues = []

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def check_arm(protocol_id, all=false)
      puts ""
      arms = Protocol.find(protocol_id.to_i).arms
      arms.each do |arm|
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
      end
    end

    protocol_id = prompt("Enter protocol id: (leave blank to check all arms in the database) ") 

    if protocol_id.to_i >= 1
      check_arm(protocol_id)
    else
      Arm.all.each do |arm|
        check_arm(arm.id, true)
      end
    end

    puts ""
    puts $arms_with_issues.inspect

  end
end
