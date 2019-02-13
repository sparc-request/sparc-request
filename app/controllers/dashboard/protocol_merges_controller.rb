class Dashboard::ProtocolMergesController < Dashboard::BaseController
  before_action :authorize_overlord
  respond_to :json, :html

  def show
    @user = current_identity
  end

  def perform_protocol_merge
    merge_srs = Dashboard::MergeSrs.new()

    master_protocol = Protocol.where(id: params[:master_protocol_id].to_i).first
    sub_protocol = Protocol.where(id: params[:sub_protocol_id].to_i).first

    if (master_protocol == nil) || (sub_protocol == nil)
      flash[:alert] = 'Protocol(s) not found. Check IDs and try again.'
    else
      ActiveRecord::Base.transaction do

        #transfer the project roles as needed
        sub_protocol.project_roles.each do |role|
          if role.role != 'primary-pi' && role_should_be_assigned?(role, master_protocol)
            role.update_attributes(protocol_id: master_protocol.id)
          end
        end

        # checking for and assigning research types, impact areas, and affiliations...
        if has_research?(sub_protocol, 'human_subjects') && !has_research?(master_protocol, 'human_subjects')
          sub_protocol.human_subjects_info.update_attributes(protocol_id: master_protocol.id)
        elsif has_research?(sub_protocol, 'vertebrate_animals') && !has_research?(master_protocol, 'vertebrate_animals')
          sub_protocol.vertebrate_animals_info.update_attributes(protocol_id: master_protocol.id)
        elsif has_research?(sub_protocol, 'investigational_products') && !has_research?(master_protocol, 'investigational_products')
          sub_protocol.investigational_products_info.update_attributes(protocol_id: master_protocol.id)
        elsif has_research?(sub_protocol, 'ip_patents') && !has_research?(master_protocol, 'ip_patents')
          sub_protocol.ip_patents_info.update_attributes(protocol_id: master_protocol.id)
        end

        sub_protocol.impact_areas.each do |area|
          area.protocol_id = master_protocol.id
          area.save(validate: false)
        end

        sub_protocol.affiliations.each do |affiliation|
          affiliation.protocol_id = master_protocol.id
          affiliation.save(validate: false)
        end

        # assigning service requests...
        fulfillment_ssrs = []
        sub_protocol.service_requests.each do |request|
          request.protocol_id = master_protocol.id
          request.save(validate: false)
          request.sub_service_requests.each do |ssr|
            ssr.update_attributes(protocol_id: master_protocol.id)
            master_protocol.next_ssr_id = (master_protocol.next_ssr_id + 1)
            master_protocol.save(validate: false)
            if ssr.in_work_fulfillment
              fulfillment_ssrs << ssr
            end
          end
        end

        #assigning arms..."
        sub_protocol.arms.each do |arm|
          check_arm_names(arm, master_protocol)
          arm.protocol_id = master_protocol.id
          arm.save(validate: false)
        end

        #assigning documents..."
        sub_protocol.documents.each do |document|
          document.protocol_id = master_protocol.id
          document.save(validate: false)
        end

        #assigning_notes
        sub_protocol.notes.each do |note|
          note.notable_id = master_protocol.id
          note.save(validate: false)
        end

        #delete sub protocol
        sub_protocol.delete

        #cleanup
        merge_srs.perform_sr_merge
      end
      flash[:success] = 'Protocol merge succesful'
    end
  end

  private

  def role_should_be_assigned?(role_to_be_assigned, protocol)
    protocol.project_roles.each do |role|
      if (role.role == role_to_be_assigned.role) && (role.identity_id == role_to_be_assigned.identity_id)
        return false
      end
    end
    return true
  end

  def authorize_overlord
    unless @user.catalog_overlord?
      render partial: 'service_requests/authorization_error',
        locals: { error: 'You do not have access to perform a Protocol Merge',
                  in_dashboard: false
      }
    end
  end
end