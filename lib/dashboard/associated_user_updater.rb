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
  class AssociatedUserUpdater
    attr_reader :protocol_role

    def initialize(params)
      @protocol_role = ProjectRole.find(params[:id])
      protocol = @protocol_role.protocol

      epic_rights = @protocol_role.epic_rights.to_a # use to_a to eval ActiveRecord::Relation
      @protocol_role.assign_attributes(params[:project_role])

      if @protocol_role.fully_valid?
        @success = true
        # flash.now[:success] = 'Authorized User Updated!'

        if @protocol_role.role == 'primary-pi'
          protocol.project_roles.where(role: 'primary-pi').where.not(identity_id: @protocol_role.identity_id).each do |pr|
            pr.update_attributes(project_rights: 'request', role: 'general-access-user')
          end
        end

        access_removed = @protocol_role.epic_access_changed?(to: false)
        access_granted = @protocol_role.epic_access_changed?(to: true)

        # must come after the use of ActiveModel::Dirty methods above
        @protocol_role.save

        if USE_EPIC && protocol.selected_for_epic && !QUEUE_EPIC
          if access_removed
            Notifier.notify_for_epic_access_removal(protocol, @protocol_role).deliver
          elsif access_granted
            Notifier.notify_for_epic_user_approval(protocol).deliver
          elsif epic_rights != @protocol_role.epic_rights.to_a
            Notifier.notify_for_epic_rights_changes(protocol, @protocol_role, epic_rights).deliver
          end
        end
      else
        @success = false
      end
    end

    def successful?
      @success
    end

    def protocol_role
      @protocol_role
    end
  end
end
