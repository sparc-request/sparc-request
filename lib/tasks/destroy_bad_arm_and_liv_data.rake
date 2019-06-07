# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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