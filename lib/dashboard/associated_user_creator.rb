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
        if SEND_AUTHORIZED_USER_EMAILS
          protocol.emailed_associated_users.each do |project_role|
            UserMailer.authorized_user_changed(project_role.identity, protocol).deliver unless project_role.identity.email.blank?
          end
        end

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
