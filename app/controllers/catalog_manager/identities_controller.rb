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

class CatalogManager::IdentitiesController < CatalogManager::AppController
  respond_to :json
  layout false

  def associate_with_org_unit
    org_unit_id = params["org_unit"]
    identity_id = params["identity"]
    rel_type = params["rel_type"]

    #oe = ObisEntity.find org_unit_id
    oe = Organization.find org_unit_id
    identity = Identity.find identity_id

    if rel_type == 'service_provider_organizational_unit'
      if not oe.service_providers or (oe.service_providers and not oe.service_providers.map(&:id).include? identity_id)
        # we have a new relationship to create
        #identity.create_relationship_to oe.id, 'service_provider_organizational_unit', {"view_draft_status" => false, "is_primary_contact" => false, "hold_emails" => false}
        service_provider = oe.service_providers.new
        service_provider.identity = identity
        service_provider.save
      end

      render :partial => 'catalog_manager/shared/service_providers', :locals => {:entity => oe}

    elsif rel_type == 'super_user_organizational_unit'
      if not oe.super_users or (oe.super_users and not oe.super_users.map(&:id).include? identity_id)
        # we have a new relationship to create
        #identity.create_relationship_to oe.id, 'super_user_organizational_unit'
        super_user = oe.super_users.new
        super_user.identity = identity
        super_user.save
      end

      render :partial => 'catalog_manager/shared/super_users', :locals => {:entity => oe}

    elsif rel_type == 'clinical_provider_organizational_unit'
      if not oe.clinical_providers or (oe.clinical_providers and not oe.clinical_providers.map(&:id).include? identity_id)
        # we have a new relationship to create
        #identity.create_relationship_to oe.id, 'super_user_organizational_unit'
        clinical_provider = oe.clinical_providers.new
        clinical_provider.identity = identity
        clinical_provider.save
      end

      render :partial => 'catalog_manager/shared/clinical_providers', :locals => {:entity => oe}

    elsif rel_type == 'catalog_manager_organizational_unit'
      if not oe.catalog_managers or (oe.catalog_managers and not oe.catalog_managers.map(&:id).include? identity_id)
        # we have a new relationship to create
        #identity.create_relationship_to oe.id, 'catalog_manager_organizational_unit'
        catalog_manager = oe.catalog_managers.new
        catalog_manager.identity = identity
        catalog_manager.save
      end

      render :partial => 'catalog_manager/shared/catalog_managers', :locals => {:entity => oe}
    end
  end

  def disassociate_with_org_unit
    rel_type = params["rel_type"]
    relationship = params["relationship"]

    oe = Organization.find params["org_unit"]

    if rel_type == 'service_provider_organizational_unit'
      service_provider = ServiceProvider.find params["relationship"]
      @service_provider_error_message = nil
      
      # we need to have more than just this one service provider in the tree in order to delete
      # if we have services we only need to verify that a service provider exists above us
      # otherwise we look in the entire tree for at least one service provider
      if (oe.services.empty? and oe.service_providers_for_child_services?) or (oe.all_service_providers(false).size > 1)
        service_provider.destroy
        oe.reload
      else
        @service_provider_error_message = I18n.t("organization_form.service_provider_required_message") 
      end
      
      render :partial => 'catalog_manager/shared/service_providers', :locals => {:entity => oe}

    elsif rel_type == 'super_user_organizational_unit'
      super_user = SuperUser.find params["relationship"]
      super_user.destroy
      render :partial => 'catalog_manager/shared/super_users', :locals => {:entity => oe}
    elsif rel_type == 'clinical_provider_organizational_unit'
      clinical_provider = ClinicalProvider.find params["relationship"]
      clinical_provider.destroy
      render :partial => 'catalog_manager/shared/clinical_providers', :locals => {:entity => oe}
    elsif rel_type == 'catalog_manager_organizational_unit'
      catalog_manager = CatalogManager.find params["relationship"]
      catalog_manager.destroy
      render :partial => 'catalog_manager/shared/catalog_managers', :locals => {:entity => oe}
    end
  end

  ########Not addressed yet, doesn't appear in coffescript/js########
  def set_view_draft_status
    rel_id       = params["rel_id"]
    status_flag  = params["status_flag"] == "true"
    contact_flag = params["contact_flag"] == "true"
    emails_flag  = params["emails_flag"] == "true"

    atts = {:view_draft_status => status_flag == false, :is_primary_contact => contact_flag, :hold_emails => emails_flag}

    @rel = {
      'relationship_type' => 'service_provider_organizational_unit',
      'attributes'        => atts,
      'from'              => params["identity"],
      'to'                => params["org_id"]
    }

    identity = Identity.find params["identity"]
    oe = ObisEntity.find params["org_id"]

    identity.update_relationship rel_id, @rel

    render :partial => 'catalog_manager/shared/service_providers', :locals => {:entity => oe}
  end

  def set_primary_contact
    service_provider = ServiceProvider.find params["service_provider"]
    oe = Organization.find params["org_id"]

    #Toggle
    if service_provider.is_primary_contact
      service_provider.is_primary_contact = false
    else
      service_provider.is_primary_contact = true
    end

    service_provider.save

    render :partial => 'catalog_manager/shared/service_providers', :locals => {:entity => oe}
  end

  def set_hold_emails
    service_provider = ServiceProvider.find params["service_provider"]
    oe = Organization.find params["org_id"]

    #Toggle
    if service_provider.hold_emails
      service_provider.hold_emails = false
    else
      service_provider.hold_emails = true
    end

    service_provider.save

    render :partial => 'catalog_manager/shared/service_providers', :locals => {:entity => oe}
  end

  def set_edit_historic_data
    manager = CatalogManager.find params["manager"]
    oe = Organization.find params["org_id"]

    #Toggle
    if manager.edit_historic_data
      manager.edit_historic_data = false
    else
      manager.edit_historic_data = true
    end

    manager.save
    
    render :partial => 'catalog_manager/shared/catalog_managers', :locals => {:entity => oe}
  end

  def search
    term = params[:term].strip
    results = Identity.search(term).map do |i| 
      {
       :label => i.display_name, :value => i.id, :email => i.email, :institution => i.institution, :phone => i.phone, :era_commons_name => i.era_commons_name,
       :college => i.college, :department => i.department, :credentials => i.credentials, :credentials_other => i.credentials_other
      }
    end
    results = [{:label => 'No Results'}] if results.empty?
    render :json => results.to_json
  end
end
