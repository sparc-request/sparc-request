# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

RSpec.configure do |config|
  
  config.before :all do
    build_impact_areas
    build_statuses
    build_user_roles
    build_proxy_rights
    build_funding_sources
    build_potential_funding_sources
    build_user_credentials
    build_document_types
  end
end

def build_impact_areas
  create(:permissible_value, category: 'impact_area', key: 'pediatrics', value: 'Pediatrics')
  create(:permissible_value, category: 'impact_area', key: 'hiv_aids', value: 'HIV/AIDS')
  create(:permissible_value, category: 'impact_area', key: 'hypertension', value: 'Hypertension')
  create(:permissible_value, category: 'impact_area', key: 'stroke', value: 'Stroke')
  create(:permissible_value, category: 'impact_area', key: 'diabetes', value: 'Diabetes')
  create(:permissible_value, category: 'impact_area', key: 'cancer', value: 'Cancer')
  create(:permissible_value, category: 'impact_area', key: 'community', value: 'Community Engagement')
  create(:permissible_value, category: 'impact_area', key: 'other', value: 'Other')
end

def build_statuses
  create(:permissible_value, category: 'status', key: 'ctrc_approved', value: 'Active')
  create(:permissible_value, category: 'status', key: 'administrative_review', value: 'Administrative Review')
  create(:permissible_value, category: 'status', key: 'approved', value: 'Approved')
  create(:permissible_value, category: 'status', key: 'awaiting_pi_approval', value: 'Awaiting Requester Response')
  create(:permissible_value, category: 'status', key: 'complete', value: 'Complete')
  create(:permissible_value, category: 'status', key: 'declined', value: 'Declined')
  create(:permissible_value, category: 'status', key: 'draft', value: 'Draft')
  create(:permissible_value, category: 'status', key: 'get_a_cost_estimate', value: 'Get a Cost Estimate')
  create(:permissible_value, category: 'status', key: 'invoiced', value: 'Invoiced')
  create(:permissible_value, category: 'status', key: 'ctrc_review', value: 'In Admin review')
  create(:permissible_value, category: 'status', key: 'committee_review', value: 'In Committee Review')
  create(:permissible_value, category: 'status', key: 'fulfillment_queue', value: 'In Fulfillment Queue')
  create(:permissible_value, category: 'status', key: 'in_process', value: 'In Process')
  create(:permissible_value, category: 'status', key: 'on_hold', value: 'On Hold')
  create(:permissible_value, category: 'status', key: 'submitted', value: 'Submitted')
  create(:permissible_value, category: 'status', key: 'withdrawn', value: 'Withdrawn')
end

def build_user_roles
  create(:permissible_value, category: 'user_role', key: 'primary-pi', value: 'Primary PI')
  create(:permissible_value, category: 'user_role', key: 'pi', value: 'PD/PI')
  create(:permissible_value, category: 'user_role', key: 'business-grants-manager', value: 'Billing/Business Manager')
  create(:permissible_value, category: 'user_role', key: 'consultant', value: 'Consultant')
  create(:permissible_value, category: 'user_role', key: 'co-investigator', value: 'Co-Investigator')
  create(:permissible_value, category: 'user_role', key: 'mentor', value: 'Mentor')
  create(:permissible_value, category: 'user_role', key: 'other', value: 'Other')
end

def build_proxy_rights
  create(:permissible_value, category: 'proxy_right', key: 'none', value: 'Member Only')
  create(:permissible_value, category: 'proxy_right', key: 'view', value: 'View Rights')
  create(:permissible_value, category: 'proxy_right', key: 'approve', value: 'Authorize/Change Study Charges')
end

def build_funding_sources
  create(:permissible_value, category: 'funding_source', key: 'college', value: 'College')
  create(:permissible_value, category: 'funding_source', key: 'federal', value: 'Federal')
  create(:permissible_value, category: 'funding_source', key: 'foundation', value: 'Foundation/Organization')
  create(:permissible_value, category: 'funding_source', key: 'industry', value: 'Industry-Initiated/Industry-Sponsored')
  create(:permissible_value, category: 'funding_source', key: 'investigator', value: 'Investigator-Initiated/Industry-Sponsored')
  create(:permissible_value, category: 'funding_source', key: 'internal', value: 'Internal Funded Pilot Project')
  create(:permissible_value, category: 'funding_source', key: 'unfunded', value: 'Student Funded Research')
end

def build_potential_funding_sources
  create(:permissible_value, category: 'potential_funding_source', key: 'college', value: 'College')
  create(:permissible_value, category: 'potential_funding_source', key: 'federal', value: 'Federal')
  create(:permissible_value, category: 'potential_funding_source', key: 'foundation', value: 'Foundation/Organization')
  create(:permissible_value, category: 'potential_funding_source', key: 'industry', value: 'Industry-Initiated/Industry-Sponsored')
  create(:permissible_value, category: 'potential_funding_source', key: 'investigator', value: 'Investigator-Initiated/Industry-Sponsored')
  create(:permissible_value, category: 'potential_funding_source', key: 'internal', value: 'Internal Funded Pilot Project')
  create(:permissible_value, category: 'potential_funding_source', key: 'unfunded', value: 'Student Funded Research')
end

def build_user_credentials
  create(:permissible_value, category: 'user_credential', key: 'adn', value: 'ADN')
  create(:permissible_value, category: 'user_credential', key: 'ba', value: 'BA')
  create(:permissible_value, category: 'user_credential', key: 'bsn', value: 'BSN')
  create(:permissible_value, category: 'user_credential', key: 'dds', value: 'DDS')
  create(:permissible_value, category: 'user_credential', key: 'dmd', value: 'DMD')
  create(:permissible_value, category: 'user_credential', key: 'dnp', value: 'DNP')
  create(:permissible_value, category: 'user_credential', key: 'osteopathic', value: 'DO')
  create(:permissible_value, category: 'user_credential', key: 'dvm', value: 'DVM')
  create(:permissible_value, category: 'user_credential', key: 'ma', value: 'MA')
  create(:permissible_value, category: 'user_credential', key: 'mba', value: 'MBA')
  create(:permissible_value, category: 'user_credential', key: 'md', value: 'MD')
  create(:permissible_value, category: 'user_credential', key: 'md_phd', value: 'MD/PHD')
  create(:permissible_value, category: 'user_credential', key: 'ms', value: 'MS')
  create(:permissible_value, category: 'user_credential', key: 'msn', value: 'MSN')
  create(:permissible_value, category: 'user_credential', key: 'pharmd', value: 'PharmD')
  create(:permissible_value, category: 'user_credential', key: 'phd', value: 'PhD')
  create(:permissible_value, category: 'user_credential', key: 'rn', value: 'RN')
  create(:permissible_value, category: 'user_credential', key: 'none', value: 'None')
  create(:permissible_value, category: 'user_credential', key: 'other', value: 'Other')
end

def build_document_types
  create(:permissible_value, category: 'document_type', key: 'biosketch', value: 'Biosketch')
  create(:permissible_value, category: 'document_type', key: 'budget', value: 'Budget')
  create(:permissible_value, category: 'document_type', key: 'oral_health_cobre', value: 'Certificate of Confidentiality')
  create(:permissible_value, category: 'document_type', key: 'consent', value: 'Consent')
  create(:permissible_value, category: 'document_type', key: 'contract', value: 'Contract')
  create(:permissible_value, category: 'document_type', key: 'coverage_analysis', value: 'Coverage Analysis')
  create(:permissible_value, category: 'document_type', key: 'dsmp', value: 'DSMP')
  create(:permissible_value, category: 'document_type', key: 'feasibility', value: 'Feasibility / Site Selection')
  create(:permissible_value, category: 'document_type', key: 'hipaa', value: 'HIPAA')
  create(:permissible_value, category: 'document_type', key: 'investigator_brochure', value: 'Investigator Brochure')
  create(:permissible_value, category: 'document_type', key: 'justification', value: 'Justification')
  create(:permissible_value, category: 'document_type', key: 'manuals', value: 'Manuals (Pharmacy, Lab, Imaging, etc)')
  create(:permissible_value, category: 'document_type', key: 'ocr_approval', value: 'OCR Approval')
  create(:permissible_value, category: 'document_type', key: 'protocol', value: 'Protocol')
  create(:permissible_value, category: 'document_type', key: 'other', value: 'Other')

end
