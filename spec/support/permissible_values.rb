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

def populate_permissible_values_before_suite
  ActiveRecord::Base.transaction do
    build_impact_areas
    build_statuses
    build_user_roles
    build_proxy_rights
    build_funding_sources
    build_potential_funding_sources
    build_user_credentials
    build_document_types
    build_funding_statuses
    build_short_interactions
  end
end

def build_impact_areas
  FactoryBot.create(:permissible_value, category: 'impact_area', key: 'pediatrics', value: 'Pediatrics')
  FactoryBot.create(:permissible_value, category: 'impact_area', key: 'hiv_aids', value: 'HIV/AIDS')
  FactoryBot.create(:permissible_value, category: 'impact_area', key: 'hypertension', value: 'Hypertension')
  FactoryBot.create(:permissible_value, category: 'impact_area', key: 'stroke', value: 'Stroke')
  FactoryBot.create(:permissible_value, category: 'impact_area', key: 'diabetes', value: 'Diabetes')
  FactoryBot.create(:permissible_value, category: 'impact_area', key: 'cancer', value: 'Cancer')
  FactoryBot.create(:permissible_value, category: 'impact_area', key: 'community', value: 'Community Engagement')
  FactoryBot.create(:permissible_value, category: 'impact_area', key: 'other', value: 'Other')
end

def build_statuses
  FactoryBot.create(:permissible_value, category: 'status', key: 'ctrc_approved', value: 'Active', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'administrative_review', value: 'Administrative Review', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'approved', value: 'Approved', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'awaiting_pi_approval', value: 'Awaiting Requester Response', default: true)
  FactoryBot.create(:permissible_value, category: 'status', key: 'complete', value: 'Complete', default: true)
  FactoryBot.create(:permissible_value, category: 'status', key: 'declined', value: 'Declined', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'draft', value: 'Draft', default: true)
  FactoryBot.create(:permissible_value, category: 'status', key: 'get_a_cost_estimate', value: 'Get a Cost Estimate', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'invoiced', value: 'Invoiced', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'ctrc_review', value: 'In Admin review', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'committee_review', value: 'In Committee Review', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'fulfillment_queue', value: 'In Fulfillment Queue', default: false)
  FactoryBot.create(:permissible_value, category: 'status', key: 'in_process', value: 'In Process', default: true)
  FactoryBot.create(:permissible_value, category: 'status', key: 'on_hold', value: 'On Hold', default: true)
  FactoryBot.create(:permissible_value, category: 'status', key: 'submitted', value: 'Submitted', default: true)
  FactoryBot.create(:permissible_value, category: 'status', key: 'withdrawn', value: 'Withdrawn', default: false)
end

def build_user_roles
  FactoryBot.create(:permissible_value, category: 'user_role', key: 'primary-pi', value: 'Primary PI')
  FactoryBot.create(:permissible_value, category: 'user_role', key: 'pi', value: 'PD/PI')
  FactoryBot.create(:permissible_value, category: 'user_role', key: 'business-grants-manager', value: 'Billing/Business Manager')
  FactoryBot.create(:permissible_value, category: 'user_role', key: 'consultant', value: 'Consultant')
  FactoryBot.create(:permissible_value, category: 'user_role', key: 'co-investigator', value: 'Co-Investigator')
  FactoryBot.create(:permissible_value, category: 'user_role', key: 'mentor', value: 'Mentor')
  FactoryBot.create(:permissible_value, category: 'user_role', key: 'other', value: 'Other')
end

def build_proxy_rights
  FactoryBot.create(:permissible_value, category: 'proxy_right', key: 'none', value: 'Member Only')
  FactoryBot.create(:permissible_value, category: 'proxy_right', key: 'view', value: 'View Rights')
  FactoryBot.create(:permissible_value, category: 'proxy_right', key: 'approve', value: 'Authorize/Change Study Charges')
end

def build_funding_sources
  FactoryBot.create(:permissible_value, category: 'funding_source', key: 'college', value: 'College Department')
  FactoryBot.create(:permissible_value, category: 'funding_source', key: 'federal', value: 'Federal')
  FactoryBot.create(:permissible_value, category: 'funding_source', key: 'foundation', value: 'Foundation/Organization')
  FactoryBot.create(:permissible_value, category: 'funding_source', key: 'industry', value: 'Industry-Initiated/Industry-Sponsored')
  FactoryBot.create(:permissible_value, category: 'funding_source', key: 'investigator', value: 'Investigator-Initiated/Industry-Sponsored')
  FactoryBot.create(:permissible_value, category: 'funding_source', key: 'internal', value: 'Internal Funded Pilot Project')
  FactoryBot.create(:permissible_value, category: 'funding_source', key: 'unfunded', value: 'Student Funded Research')
end

def build_potential_funding_sources
  FactoryBot.create(:permissible_value, category: 'potential_funding_source', key: 'college', value: 'College Department')
  FactoryBot.create(:permissible_value, category: 'potential_funding_source', key: 'federal', value: 'Federal')
  FactoryBot.create(:permissible_value, category: 'potential_funding_source', key: 'foundation', value: 'Foundation/Organization')
  FactoryBot.create(:permissible_value, category: 'potential_funding_source', key: 'industry', value: 'Industry-Initiated/Industry-Sponsored')
  FactoryBot.create(:permissible_value, category: 'potential_funding_source', key: 'investigator', value: 'Investigator-Initiated/Industry-Sponsored')
  FactoryBot.create(:permissible_value, category: 'potential_funding_source', key: 'internal', value: 'Internal Funded Pilot Project')
  FactoryBot.create(:permissible_value, category: 'potential_funding_source', key: 'unfunded', value: 'Student Funded Research')
end

def build_user_credentials
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'adn', value: 'ADN')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'ba', value: 'BA')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'bsn', value: 'BSN')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'dds', value: 'DDS')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'dmd', value: 'DMD')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'dnp', value: 'DNP')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'osteopathic', value: 'DO')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'dvm', value: 'DVM')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'ma', value: 'MA')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'mba', value: 'MBA')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'md', value: 'MD')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'md_phd', value: 'MD/PHD')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'ms', value: 'MS')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'msn', value: 'MSN')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'pharmd', value: 'PharmD')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'phd', value: 'PhD')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'rn', value: 'RN')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'none', value: 'None')
  FactoryBot.create(:permissible_value, category: 'user_credential', key: 'other', value: 'Other')
end

def build_document_types
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'biosketch', value: 'Biosketch')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'budget', value: 'Budget')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'oral_health_cobre', value: 'Certificate of Confidentiality')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'consent', value: 'Consent')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'contract', value: 'Contract')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'coverage_analysis', value: 'Coverage Analysis')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'dsmp', value: 'DSMP')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'feasibility', value: 'Feasibility / Site Selection')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'hipaa', value: 'HIPAA')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'investigator_brochure', value: 'Investigator Brochure')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'justification', value: 'Justification')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'manuals', value: 'Manuals (Pharmacy, Lab, Imaging, etc)')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'ocr_approval', value: 'OCR Approval')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'protocol', value: 'Protocol')
  FactoryBot.create(:permissible_value, category: 'document_type', key: 'other', value: 'Other')
end


def build_funding_statuses
  FactoryBot.create(:permissible_value, category: 'funding_status', key: 'pending_funding', value: 'Pending Funding')
  FactoryBot.create(:permissible_value, category: 'funding_status', key: 'funded', value: 'Funded')
end

def build_short_interactions
  FactoryBot.create(:permissible_value, category: 'interaction_type', key: 'phone', value: 'Telephone')
  FactoryBot.create(:permissible_value, category: 'interaction_type', key: 'email', value: 'Email')
  FactoryBot.create(:permissible_value, category: 'interaction_type', key: 'in_person', value: 'In-Person')
  FactoryBot.create(:permissible_value, category: 'interaction_subject', key: 'general_question', value: 'General Questionn')
  FactoryBot.create(:permissible_value, category: 'institution', key: 'other', value: 'Other')
end
