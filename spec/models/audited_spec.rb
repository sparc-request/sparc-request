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

require 'ostruct'
require 'rails_helper'

# modified:   app/models/affiliation.rb
# # modified:   app/models/appointment.rb
# # modified:   app/models/approval.rb
# # modified:   app/models/arm.rb
# # modified:   app/models/available_status.rb
# # modified:   app/models/calendar.rb
# # modified:   app/models/catalog_manager.rb
# # modified:   app/models/charge.rb
# # modified:   app/models/document.rb
# # modified:   app/models/document_grouping.rb
# # modified:   app/models/excluded_funding_source.rb
# # modified:   app/models/feedback.rb
# # modified:   app/models/fulfillment.rb
# # modified:   app/models/human_subjects_info.rb
# # modified:   app/models/identity.rb
# # modified:   app/models/impact_area.rb
# # modified:   app/models/investigational_products_info.rb
# # modified:   app/models/ip_patents_info.rb
# # modified:   app/models/line_item.rb
# # modified:   app/models/line_items_visit.rb
# # modified:   app/models/message.rb
# # modified:   app/models/note.rb
# # modified:   app/models/notification.rb
# # modified:   app/models/organization.rb
# # modified:   app/models/past_status.rb
# # modified:   app/models/pricing_map.rb
# # modified:   app/models/pricing_setup.rb
# # modified:   app/models/procedure.rb
# # modified:   app/models/program.rb
# # modified:   app/models/project_role.rb
# # modified:   app/models/protocol.rb
# # modified:   app/models/question.rb
# # modified:   app/models/research_types_info.rb
# # modified:   app/models/service.rb
# # modified:   app/models/service_provider.rb
# # modified:   app/models/service_relation.rb
# # modified:   app/models/service_request.rb
# # modified:   app/models/study.rb
# # modified:   app/models/study_type.rb
# # modified:   app/models/sub_service_request.rb
# # modified:   app/models/subject.rb
# # modified:   app/models/submission_email.rb
# # modified:   app/models/subsidy.rb
# # modified:   app/models/subsidy_map.rb
# # modified:   app/models/super_user.rb
# # modified:   app/models/toast_message.rb
# # modified:   app/models/token.rb
# # modified:   app/models/user_notification.rb
# # modified:   app/models/vertebrate_animals_info.rb
# # modified:   app/models/visit.rb
# # modified:   app/models/visit_group.rb

RSpec.describe 'Audit trail' do
  to_test = [
    OpenStruct.new(class_name: 'Affiliation',                 key: 'name',               value: 'Foo Bar Baz'),
    OpenStruct.new(class_name: 'Approval',                    key: 'approval_date',      value: Date.parse('1914-08-01')),
    OpenStruct.new(class_name: 'CatalogManager',              key: 'organization_id',    value: 424242),
    OpenStruct.new(class_name: 'Charge',                      key: 'charge_amount',      value: 42.42),
    # OpenStruct.new(class_name: 'Document',         key: 'doc_type',           value: 'foobarbaz'),
    # OpenStruct.new(class_name: 'DocumentGrouping', key: 'service_request_id', value: 424242),
    OpenStruct.new(class_name: 'ExcludedFundingSource',       key: 'subsidy_map_id',     value: 424242),
    OpenStruct.new(class_name: 'Fulfillment',                 key: 'date',               value: Date.parse('1914-08-01')),
    OpenStruct.new(class_name: 'HumanSubjectsInfo',           key: 'submission_type',    value: 'foobarbaz'),
    #FIXME OpenStruct.new(class_name: 'Identity',                    key: 'email',              value: 'foo@bar.baz'),
    OpenStruct.new(class_name: 'ImpactArea',                  key: 'name',               value: 'hi funny people'),
    OpenStruct.new(class_name: 'InvestigationalProductsInfo', key: 'ind_number',         value: 4242),
    OpenStruct.new(class_name: 'LineItem',                    key: 'quantity',           value: 42),
    OpenStruct.new(class_name: 'PastStatus',                  key: 'date',               value: Date.parse('1914-08-01')),
    OpenStruct.new(class_name: 'PricingMap',                  key: 'full_rate',          value: 0.42),
    OpenStruct.new(class_name: 'PricingSetup',                key: 'college_rate_type',  value: 'hahaha'),
    OpenStruct.new(class_name: 'ProjectRole',                 key: 'role',       value: 'awesomness'),
    OpenStruct.new(class_name: 'Service',                     key: 'description',        value: 'some useless service'),
    OpenStruct.new(class_name: 'ServiceProvider',             key: 'organization_id',    value: 424242),
    OpenStruct.new(class_name: 'ServiceRelation',             key: 'related_service_id', value: 424242),
    OpenStruct.new(class_name: 'ServiceRequest',              key: 'start_date',         value: Date.parse('1914-08-01')),
    OpenStruct.new(class_name: 'StudyType',                   key: 'name',               value: 'imaginary_science'),
    OpenStruct.new(class_name: 'SubServiceRequest',           key: 'status_date',        value: Date.parse('1914-08-01')),
    OpenStruct.new(class_name: 'SubmissionEmail',             key: 'email',              value: 'billg@microsoft.com'),
    OpenStruct.new(class_name: 'Subsidy',                     key: 'pi_contribution',    value: 424242),
    OpenStruct.new(class_name: 'SubsidyMap',                  key: 'max_percentage',     value: 0.42),
    OpenStruct.new(class_name: 'SuperUser',                   key: 'organization_id',    value: 424242),
    OpenStruct.new(class_name: 'Token',                       key: 'token',              value: 'token black student'),
    OpenStruct.new(class_name: 'VertebrateAnimalsInfo',       key: 'iacuc_number',       value: 4242),
    OpenStruct.new(class_name: 'Visit',                       key: 'quantity',           value: 24),

    OpenStruct.new(class_name: 'Organization',                key: 'name',               value: 'my useless organization'),
    OpenStruct.new(class_name: 'Core',                        key: 'name',               value: 'my useless organization'),
    OpenStruct.new(class_name: 'Program',                     key: 'name',               value: 'my useless organization'),
    OpenStruct.new(class_name: 'Provider',                    key: 'name',               value: 'my useless organization'),
    OpenStruct.new(class_name: 'Institution',                 key: 'name',               value: 'my useless organization'),

    OpenStruct.new(class_name: 'Protocol',                    key: 'title',              value: 'my useless project'),
  ]

  to_test.each do |entity|
    describe entity.class_name do
      # it 'should include audit information' do
      #   attrs = attributes_for(entity.class_name.underscore.to_sym)
      #   record = entity.class_name.constantize.new(attrs)
      #   record.save!(validate: false)
      #   orig_value = record[entity.key]

      #   record[entity.key] = entity.value
      #   record.save!(validate: false)
      #   record[entity.key].should eq entity.value
      #   new_value = record[entity.key]

      #   record.audits.last.audited_changes[entity.key].should include(orig_value, new_value)
      # end
    end
  end
end
