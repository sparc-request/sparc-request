# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

task :has_duplicate_line_items_visits => :environment do

  def prompt(*args)
      print(*args)
      STDIN.gets.strip
  end

  def display_protocol_status(has_duplicates, protocol_id)
    if has_duplicates == true
      puts "Protocol #{protocol_id} needs to be repushed to Epic"
    else
      puts "No duplicates were found for #{protocol_id}"
    end
  end

  def check_arms(arms)
    has_duplicates = false
    arms.each do |arm|
      livs = arm.line_items_visits.group_by(&:line_item_id)
      livs.values.each do |liv_array|
        if liv_array.size > 1
          has_duplicates = true
        end
      end
    end

    has_duplicates
  end

  puts "This task will determine if a given protocol needs to be repushed to Epic"
  puts "due to it having duplicate line items visits."
  continue = 'Yes'

  while continue == 'Yes'
    protocol_id = (prompt "Enter a protocol id to check: ").to_i
    arms = Protocol.find(protocol_id).arms
    has_duplicates = check_arms(arms)

    display_protocol_status(has_duplicates, protocol_id)
    continue = prompt "Check another protocol? (Yes/No): "
  end
end