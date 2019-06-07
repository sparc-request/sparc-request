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

desc "Task for merging service requests under a protocol"
task :merge_service_requests => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def merge_requests(service_requests)
    master_request = service_requests.shift
    puts 'The following requests are now empty and should be deleted:'
    service_requests.each do |request|
      assign_sub_service_requests(master_request, request)
      assign_line_items(master_request, request)
      puts "Service Request: #{request.id}"
    end
  end

  def assign_sub_service_requests(master_request, request)
    request.sub_service_requests.each do |ssr|
      ssr.update_attributes(service_request_id: master_request.id)
    end
  end

  def assign_line_items(master_request, request)
    request.line_items.each do |line_item|
      line_item.update_attributes(service_request_id: master_request.id)
    end 
  end

  puts 'This task will merge all service requests under a protocol.'
  protocol_id = prompt "Enter the ID of the protocol: "
  protocol = Protocol.find(protocol_id.to_i)

  if protocol.service_requests.size > 1
    service_requests = protocol.service_requests.order('updated_at DESC').to_a
    merge_requests(service_requests)
  else
    puts "This protocol does not have more than one service request."
  end
end