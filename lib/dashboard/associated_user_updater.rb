module Dashboard
  class AssociatedUserUpdater
    attr_reader :protocol_role

    def initialize(params)
      @protocol_role = ProjectRole.find(params[:id])
      protocol = @protocol_role.protocol
      modified_user = Identity.find(protocol_role.identity_id)
      action = 'update'

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

        protocol.email_about_change_in_authorized_user(modified_user, action)

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
