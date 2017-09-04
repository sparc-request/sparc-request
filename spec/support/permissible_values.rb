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
  
  config.before :suite do
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
  PermissibleValue.create(category: 'impact_area', key: 'pediatrics', value: 'Pediatrics')
  PermissibleValue.create(category: 'impact_area', key: 'hiv_aids', value: 'HIV/AIDS')
  PermissibleValue.create(category: 'impact_area', key: 'hypertension', value: 'Hypertension')
  PermissibleValue.create(category: 'impact_area', key: 'stroke', value: 'Stroke')
  PermissibleValue.create(category: 'impact_area', key: 'diabetes', value: 'Diabetes')
  PermissibleValue.create(category: 'impact_area', key: 'cancer', value: 'Cancer')
  PermissibleValue.create(category: 'impact_area', key: 'community', value: 'Community Engagement')
  PermissibleValue.create(category: 'impact_area', key: 'other', value: 'Other')
end

def build_statuses
  PermissibleValue.create(category: 'status', key: 'ctrc_approved', value: 'Active')
  PermissibleValue.create(category: 'status', key: 'administrative_review', value: 'Administrative Review')
  PermissibleValue.create(category: 'status', key: 'approved', value: 'Approved')
  PermissibleValue.create(category: 'status', key: 'awaiting_pi_approval', value: 'Awaiting Requester Response', default: true)
  PermissibleValue.create(category: 'status', key: 'complete', value: 'Complete', default: true)
  PermissibleValue.create(category: 'status', key: 'declined', value: 'Declined')
  PermissibleValue.create(category: 'status', key: 'draft', value: 'Draft', default: true)
  PermissibleValue.create(category: 'status', key: 'get_a_cost_estimate', value: 'Get a Cost Estimate')
  PermissibleValue.create(category: 'status', key: 'invoiced', value: 'Invoiced')
  PermissibleValue.create(category: 'status', key: 'ctrc_review', value: 'In Admin review')
  PermissibleValue.create(category: 'status', key: 'committee_review', value: 'In Committee Review')
  PermissibleValue.create(category: 'status', key: 'fulfillment_queue', value: 'In Fulfillment Queue')
  PermissibleValue.create(category: 'status', key: 'in_process', value: 'In Process', default: true)
  PermissibleValue.create(category: 'status', key: 'on_hold', value: 'On Hold', default: true)
  PermissibleValue.create(category: 'status', key: 'submitted', value: 'Submitted', default: true)
  PermissibleValue.create(category: 'status', key: 'withdrawn', value: 'Withdrawn')
end

def build_user_roles
  PermissibleValue.create(category: 'user_role', key: 'primary-pi', value: 'Primary PI')
  PermissibleValue.create(category: 'user_role', key: 'pi', value: 'PD/PI')
  PermissibleValue.create(category: 'user_role', key: 'business-grants-manager', value: 'Billing/Business Manager')
  PermissibleValue.create(category: 'user_role', key: 'consultant', value: 'Consultant')
  PermissibleValue.create(category: 'user_role', key: 'co-investigator', value: 'Co-Investigator')
  PermissibleValue.create(category: 'user_role', key: 'mentor', value: 'Mentor')
  PermissibleValue.create(category: 'user_role', key: 'other', value: 'Other')
end

def build_proxy_rights
  PermissibleValue.create(category: 'proxy_right', key: 'none', value: 'Member Only')
  PermissibleValue.create(category: 'proxy_right', key: 'view', value: 'View Rights')
  PermissibleValue.create(category: 'proxy_right', key: 'approve', value: 'Authorize/Change Study Charges')
end

def build_funding_sources
  PermissibleValue.create(category: 'funding_source', key: 'college', value: 'College Department')
  PermissibleValue.create(category: 'funding_source', key: 'federal', value: 'Federal')
  PermissibleValue.create(category: 'funding_source', key: 'foundation', value: 'Foundation/Organization')
  PermissibleValue.create(category: 'funding_source', key: 'industry', value: 'Industry-Initiated/Industry-Sponsored')
  PermissibleValue.create(category: 'funding_source', key: 'investigator', value: 'Investigator-Initiated/Industry-Sponsored')
  PermissibleValue.create(category: 'funding_source', key: 'internal', value: 'Internal Funded Pilot Project')
  PermissibleValue.create(category: 'funding_source', key: 'unfunded', value: 'Student Funded Research')
end

def build_potential_funding_sources
  PermissibleValue.create(category: 'potential_funding_source', key: 'college', value: 'College Department')
  PermissibleValue.create(category: 'potential_funding_source', key: 'federal', value: 'Federal')
  PermissibleValue.create(category: 'potential_funding_source', key: 'foundation', value: 'Foundation/Organization')
  PermissibleValue.create(category: 'potential_funding_source', key: 'industry', value: 'Industry-Initiated/Industry-Sponsored')
  PermissibleValue.create(category: 'potential_funding_source', key: 'investigator', value: 'Investigator-Initiated/Industry-Sponsored')
  PermissibleValue.create(category: 'potential_funding_source', key: 'internal', value: 'Internal Funded Pilot Project')
  PermissibleValue.create(category: 'potential_funding_source', key: 'unfunded', value: 'Student Funded Research')
end

def build_user_credentials
  PermissibleValue.create(category: 'user_credential', key: 'adn', value: 'ADN')
  PermissibleValue.create(category: 'user_credential', key: 'ba', value: 'BA')
  PermissibleValue.create(category: 'user_credential', key: 'bsn', value: 'BSN')
  PermissibleValue.create(category: 'user_credential', key: 'dds', value: 'DDS')
  PermissibleValue.create(category: 'user_credential', key: 'dmd', value: 'DMD')
  PermissibleValue.create(category: 'user_credential', key: 'dnp', value: 'DNP')
  PermissibleValue.create(category: 'user_credential', key: 'osteopathic', value: 'DO')
  PermissibleValue.create(category: 'user_credential', key: 'dvm', value: 'DVM')
  PermissibleValue.create(category: 'user_credential', key: 'ma', value: 'MA')
  PermissibleValue.create(category: 'user_credential', key: 'mba', value: 'MBA')
  PermissibleValue.create(category: 'user_credential', key: 'md', value: 'MD')
  PermissibleValue.create(category: 'user_credential', key: 'md_phd', value: 'MD/PHD')
  PermissibleValue.create(category: 'user_credential', key: 'ms', value: 'MS')
  PermissibleValue.create(category: 'user_credential', key: 'msn', value: 'MSN')
  PermissibleValue.create(category: 'user_credential', key: 'pharmd', value: 'PharmD')
  PermissibleValue.create(category: 'user_credential', key: 'phd', value: 'PhD')
  PermissibleValue.create(category: 'user_credential', key: 'rn', value: 'RN')
  PermissibleValue.create(category: 'user_credential', key: 'none', value: 'None')
  PermissibleValue.create(category: 'user_credential', key: 'other', value: 'Other')
end

def build_document_types
  PermissibleValue.create(category: 'document_type', key: 'biosketch', value: 'Biosketch')
  PermissibleValue.create(category: 'document_type', key: 'budget', value: 'Budget')
  PermissibleValue.create(category: 'document_type', key: 'oral_health_cobre', value: 'Certificate of Confidentiality')
  PermissibleValue.create(category: 'document_type', key: 'consent', value: 'Consent')
  PermissibleValue.create(category: 'document_type', key: 'contract', value: 'Contract')
  PermissibleValue.create(category: 'document_type', key: 'coverage_analysis', value: 'Coverage Analysis')
  PermissibleValue.create(category: 'document_type', key: 'dsmp', value: 'DSMP')
  PermissibleValue.create(category: 'document_type', key: 'feasibility', value: 'Feasibility / Site Selection')
  PermissibleValue.create(category: 'document_type', key: 'hipaa', value: 'HIPAA')
  PermissibleValue.create(category: 'document_type', key: 'investigator_brochure', value: 'Investigator Brochure')
  PermissibleValue.create(category: 'document_type', key: 'justification', value: 'Justification')
  PermissibleValue.create(category: 'document_type', key: 'manuals', value: 'Manuals (Pharmacy, Lab, Imaging, etc)')
  PermissibleValue.create(category: 'document_type', key: 'ocr_approval', value: 'OCR Approval')
  PermissibleValue.create(category: 'document_type', key: 'protocol', value: 'Protocol')
  PermissibleValue.create(category: 'document_type', key: 'other', value: 'Other')
end
