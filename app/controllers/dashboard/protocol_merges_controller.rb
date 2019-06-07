# Copyright © 2011-2018 MUSC Foundation for Research Development
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

class Dashboard::ProtocolMergesController < Dashboard::BaseController
  before_action :authorize_overlord
  respond_to :json, :html

  def show
    @user = current_identity
  end

  def perform_protocol_merge
    master_protocol = Protocol.where(id: params[:master_protocol_id].to_i).first
    sub_protocol = Protocol.where(id: params[:sub_protocol_id].to_i).first

    merge_srs = Dashboard::MergeSrs.new()
    fix_ssr_ids = Dashboard::FixSsrIds.new(master_protocol)

    if (master_protocol == nil) || (sub_protocol == nil)
      flash[:alert] = 'Protocol(s) not found. Check IDs and try again.'
    elsif (master_protocol.has_clinical_services? && sub_protocol.has_clinical_services?)
      flash[:alert] = 'Both protocols have calendars. Only one protocol may have a calendar for merge to work.'
    elsif sub_protocol.fulfillment_protocols.any?
      flash[:alert] = 'Protocol to be merged into Master Protocol cannot exist in SPARCFulfillment.'
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

        #log change to DB
        ProtocolMerge.create(master_protocol_id: master_protocol.id, merged_protocol_id: sub_protocol.id, identity_id: current_identity.id)

        #delete sub protocol
        sub_protocol.delete

        #cleanup
        merge_srs.perform_sr_merge
        fix_ssr_ids.perform_id_fix
      end
      flash[:success] = 'Protocol merge successful'
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

  def has_research?(protocol, research_type)
    protocol.research_types_info.try(research_type) || false
  end
end
