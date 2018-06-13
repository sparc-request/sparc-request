# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
  end
end

def build_impact_areas
  FactoryGirl.create(:permissible_value, category: 'impact_area', key: 'pediatrics', value: 'Pediatrics')
  FactoryGirl.create(:permissible_value, category: 'impact_area', key: 'hiv_aids', value: 'HIV/AIDS')
  FactoryGirl.create(:permissible_value, category: 'impact_area', key: 'hypertension', value: 'Hypertension')
  FactoryGirl.create(:permissible_value, category: 'impact_area', key: 'stroke', value: 'Stroke')
  FactoryGirl.create(:permissible_value, category: 'impact_area', key: 'diabetes', value: 'Diabetes')
  FactoryGirl.create(:permissible_value, category: 'impact_area', key: 'cancer', value: 'Cancer')
  FactoryGirl.create(:permissible_value, category: 'impact_area', key: 'community', value: 'Community Engagement')
  FactoryGirl.create(:permissible_value, category: 'impact_area', key: 'other', value: 'Other')
end

def build_statuses
  FactoryGirl.create(:permissible_value, category: 'status', key: 'ctrc_approved', value: 'Active')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'administrative_review', value: 'Administrative Review')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'approved', value: 'Approved')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'awaiting_pi_approval', value: 'Awaiting Requester Response', default: true)
  FactoryGirl.create(:permissible_value, category: 'status', key: 'complete', value: 'Complete', default: true)
  FactoryGirl.create(:permissible_value, category: 'status', key: 'declined', value: 'Declined')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'draft', value: 'Draft', default: true)
  FactoryGirl.create(:permissible_value, category: 'status', key: 'get_a_cost_estimate', value: 'Get a Cost Estimate')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'invoiced', value: 'Invoiced')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'ctrc_review', value: 'In Admin review')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'committee_review', value: 'In Committee Review')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'fulfillment_queue', value: 'In Fulfillment Queue')
  FactoryGirl.create(:permissible_value, category: 'status', key: 'in_process', value: 'In Process', default: true)
  FactoryGirl.create(:permissible_value, category: 'status', key: 'on_hold', value: 'On Hold', default: true)
  FactoryGirl.create(:permissible_value, category: 'status', key: 'submitted', value: 'Submitted', default: true)
  FactoryGirl.create(:permissible_value, category: 'status', key: 'withdrawn', value: 'Withdrawn')
end

def build_user_roles
  FactoryGirl.create(:permissible_value, category: 'user_role', key: 'primary-pi', value: 'Primary PI')
  FactoryGirl.create(:permissible_value, category: 'user_role', key: 'pi', value: 'PD/PI')
  FactoryGirl.create(:permissible_value, category: 'user_role', key: 'business-grants-manager', value: 'Billing/Business Manager')
  FactoryGirl.create(:permissible_value, category: 'user_role', key: 'consultant', value: 'Consultant')
  FactoryGirl.create(:permissible_value, category: 'user_role', key: 'co-investigator', value: 'Co-Investigator')
  FactoryGirl.create(:permissible_value, category: 'user_role', key: 'mentor', value: 'Mentor')
  FactoryGirl.create(:permissible_value, category: 'user_role', key: 'other', value: 'Other')
end

def build_proxy_rights
  FactoryGirl.create(:permissible_value, category: 'proxy_right', key: 'none', value: 'Member Only')
  FactoryGirl.create(:permissible_value, category: 'proxy_right', key: 'view', value: 'View Rights')
  FactoryGirl.create(:permissible_value, category: 'proxy_right', key: 'approve', value: 'Authorize/Change Study Charges')
end

def build_funding_sources
  FactoryGirl.create(:permissible_value, category: 'funding_source', key: 'college', value: 'College Department')
  FactoryGirl.create(:permissible_value, category: 'funding_source', key: 'federal', value: 'Federal')
  FactoryGirl.create(:permissible_value, category: 'funding_source', key: 'foundation', value: 'Foundation/Organization')
  FactoryGirl.create(:permissible_value, category: 'funding_source', key: 'industry', value: 'Industry-Initiated/Industry-Sponsored')
  FactoryGirl.create(:permissible_value, category: 'funding_source', key: 'investigator', value: 'Investigator-Initiated/Industry-Sponsored')
  FactoryGirl.create(:permissible_value, category: 'funding_source', key: 'internal', value: 'Internal Funded Pilot Project')
  FactoryGirl.create(:permissible_value, category: 'funding_source', key: 'unfunded', value: 'Student Funded Research')
end

def build_potential_funding_sources
  FactoryGirl.create(:permissible_value, category: 'potential_funding_source', key: 'college', value: 'College Department')
  FactoryGirl.create(:permissible_value, category: 'potential_funding_source', key: 'federal', value: 'Federal')
  FactoryGirl.create(:permissible_value, category: 'potential_funding_source', key: 'foundation', value: 'Foundation/Organization')
  FactoryGirl.create(:permissible_value, category: 'potential_funding_source', key: 'industry', value: 'Industry-Initiated/Industry-Sponsored')
  FactoryGirl.create(:permissible_value, category: 'potential_funding_source', key: 'investigator', value: 'Investigator-Initiated/Industry-Sponsored')
  FactoryGirl.create(:permissible_value, category: 'potential_funding_source', key: 'internal', value: 'Internal Funded Pilot Project')
  FactoryGirl.create(:permissible_value, category: 'potential_funding_source', key: 'unfunded', value: 'Student Funded Research')
end

def build_user_credentials
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'adn', value: 'ADN')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'ba', value: 'BA')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'bsn', value: 'BSN')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'dds', value: 'DDS')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'dmd', value: 'DMD')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'dnp', value: 'DNP')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'osteopathic', value: 'DO')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'dvm', value: 'DVM')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'ma', value: 'MA')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'mba', value: 'MBA')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'md', value: 'MD')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'md_phd', value: 'MD/PHD')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'ms', value: 'MS')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'msn', value: 'MSN')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'pharmd', value: 'PharmD')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'phd', value: 'PhD')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'rn', value: 'RN')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'none', value: 'None')
  FactoryGirl.create(:permissible_value, category: 'user_credential', key: 'other', value: 'Other')
end

def build_document_types
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'biosketch', value: 'Biosketch')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'budget', value: 'Budget')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'oral_health_cobre', value: 'Certificate of Confidentiality')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'consent', value: 'Consent')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'contract', value: 'Contract')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'coverage_analysis', value: 'Coverage Analysis')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'dsmp', value: 'DSMP')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'feasibility', value: 'Feasibility / Site Selection')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'hipaa', value: 'HIPAA')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'investigator_brochure', value: 'Investigator Brochure')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'justification', value: 'Justification')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'manuals', value: 'Manuals (Pharmacy, Lab, Imaging, etc)')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'ocr_approval', value: 'OCR Approval')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'protocol', value: 'Protocol')
  FactoryGirl.create(:permissible_value, category: 'document_type', key: 'other', value: 'Other')
end


def build_funding_statuses
  FactoryGirl.create(:permissible_value, category: 'funding_status', key: 'pending_funding', value: 'Pending Funding')
  FactoryGirl.create(:permissible_value, category: 'funding_status', key: 'funded', value: 'Funded')
end