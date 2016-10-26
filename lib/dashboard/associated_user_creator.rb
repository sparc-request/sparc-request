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

module Dashboard
  class AssociatedUserCreator
    attr_reader :protocol_role

    def initialize(params)
      protocol = Protocol.find(params[:protocol_id])
      @protocol_role = protocol.project_roles.build(params)

      if @protocol_role.unique_to_protocol? && @protocol_role.fully_valid?
        @successful = true
        if @protocol_role.role == 'primary-pi'
          protocol.project_roles.primary_pis.each do |pr|
            pr.update_attributes(project_rights: 'request', role: 'general-access-user')
          end
        end
        @protocol_role.save
        
        protocol.email_about_change_in_authorized_user(@protocol_role, "add")

        if USE_EPIC && protocol.selected_for_epic && !QUEUE_EPIC
          Notifier.notify_for_epic_user_approval(protocol).deliver
        end
      else
        @successful = false
      end
    end

    def successful?
      @successful
    end
  end
end
