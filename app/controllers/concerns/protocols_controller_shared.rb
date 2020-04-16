# Copyright © 2011-2019 MUSC Foundation for Research Development
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

module ProtocolsControllerShared
  extend ActiveSupport::Concern

  included do
  end

  def new
    respond_to :html

    @protocol = params[:type].capitalize.constantize.new
    @protocol.populate_for_edit
  end

  protected

  def find_protocol
    @protocol = Protocol.find(params[:id])
  end

  def protocol_params
    # Fix identity_id nil problem when lazy loading is enabled
    # when lazy loading is enabled, the identity may not exist in database yet, so we create it using lazy_identity_id if necessary here
    if Setting.get_value("use_ldap") && Setting.get_value("lazy_load_ldap") && params[:lazy_identity_id].present?
      params[:protocol][:primary_pi_role_attributes][:identity_id] = Identity.find_or_create(params[:lazy_identity_id]).id
    end

    # Sanitize date formats
    params[:protocol][:start_date]                            = sanitize_date params[:protocol][:start_date]                            if params[:protocol][:start_date]
    params[:protocol][:end_date]                              = sanitize_date params[:protocol][:end_date]                              if params[:protocol][:end_date]
    params[:protocol][:initial_budget_sponsor_received_date]  = sanitize_date params[:protocol][:initial_budget_sponsor_received_date]  if params[:protocol][:initial_budget_sponsor_received_date]
    params[:protocol][:budget_agreed_upon_date]               = sanitize_date params[:protocol][:budget_agreed_upon_date]               if params[:protocol][:budget_agreed_upon_date]
    params[:protocol][:recruitment_start_date]                = sanitize_date params[:protocol][:recruitment_start_date]                if params[:protocol][:recruitment_start_date]
    params[:protocol][:recruitment_end_date]                  = sanitize_date params[:protocol][:recruitment_end_date]                  if params[:protocol][:recruitment_end_date]
    params[:protocol][:funding_start_date]                    = sanitize_date params[:protocol][:funding_start_date]                    if params[:protocol][:funding_start_date]
    params[:protocol][:potential_funding_start_date]          = sanitize_date params[:protocol][:potential_funding_start_date]          if params[:protocol][:potential_funding_start_date]

    # Sanitize phone formats
    params[:protocol][:guarantor_phone] = sanitize_phone params[:protocol][:guarantor_phone] if params[:protocol][:guarantor_phone]

    if params[:protocol][:human_subjects_info_attributes]
      params[:protocol][:human_subjects_info_attributes][:initial_irb_approval_date] = sanitize_date params[:protocol][:human_subjects_info_attributes][:initial_irb_approval_date]
      params[:protocol][:human_subjects_info_attributes][:irb_approval_date]         = sanitize_date params[:protocol][:human_subjects_info_attributes][:irb_approval_date]
      params[:protocol][:human_subjects_info_attributes][:irb_expiration_date]       = sanitize_date params[:protocol][:human_subjects_info_attributes][:irb_expiration_date]
    end

    if params[:protocol][:vertebrate_animals_info_attributes]
      params[:protocol][:vertebrate_animals_info_attributes][:iacuc_approval_date]   = sanitize_date params[:protocol][:vertebrate_animals_info_attributes][:iacuc_approval_date]
      params[:protocol][:vertebrate_animals_info_attributes][:iacuc_expiration_date] = sanitize_date params[:protocol][:vertebrate_animals_info_attributes][:iacuc_expiration_date]
    end

    params.require(:protocol).permit(
      :archived,
      :arms_attributes,
      :billing_business_manager_static_email,
      :brief_description,
      :budget_agreed_upon_date,
      :end_date,
      :federal_grant_code_id,
      :federal_grant_serial_number,
      :federal_grant_title,
      :federal_non_phs_sponsor,
      :federal_phs_sponsor,
      :funding_rfa,
      :funding_source,
      :funding_source_other,
      :funding_start_date,
      :funding_status,
      :guarantor_contact,
      :guarantor_email,
      :guarantor_phone,
      :identity_id,
      :indirect_cost_rate,
      :initial_amount,
      :initial_amount_clinical_services,
      :initial_budget_sponsor_received_date,
      :last_epic_push_status,
      :last_epic_push_time,
      :negotiated_amount,
      :negotiated_amount_clinical_services,
      :next_ssr_id,
      :potential_funding_source,
      :potential_funding_source_other,
      :potential_funding_start_date,
      :requester_id,
      :research_master_id,
      :selected_for_epic,
      :short_title,
      :sponsor_name,
      :start_date,
      :study_type_question_group_id,
      :title,
      :type,
      :udak_project_number,
      affiliations_attributes: [:id, :name, :new, :position, :_destroy],
      human_subjects_info_attributes: [:id, :nct_number, :pro_number, :irb_of_record, :submission_type, :initial_irb_approval_date, :irb_approval_date, :irb_expiration_date, :approval_pending],
      impact_areas_attributes: [:id, :name, :other_text, :new, :_destroy],
      investigational_products_info_attributes: [:id, :protocol_id, :ind_number, :inv_device_number, :exemption_type, :ind_on_hold],
      ip_patents_info_attributes: [:id, :patent_number, :inventors],
      primary_pi_role_attributes: [:id, :identity_id, :_destroy],
      research_types_info_attributes: [:id, :human_subjects, :vertebrate_animals, :investigational_products, :ip_patents],
      study_phase_ids: [],
      study_types_attributes: [:id, :name, :new, :position, :_destroy],
      study_type_answers_attributes: [:id, :answer, :study_type_question_id, :_destroy],
      vertebrate_animals_info_attributes: [:id, :iacuc_number, :name_of_iacuc, :iacuc_approval_date, :iacuc_expiration_date]
    )
  end
end
