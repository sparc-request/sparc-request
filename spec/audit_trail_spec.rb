require 'ostruct'
require 'spec_helper'
require 'models/identity'

describe 'Audit trail' do
#  to_test = [
#    OpenStruct.new(class_name: 'Affiliation',                 key: 'name',               value: 'Foo Bar Baz'),
#    OpenStruct.new(class_name: 'Approval',                    key: 'approval_date',      value: Date.parse('1914-08-01')),
#    OpenStruct.new(class_name: 'CatalogManager',              key: 'organization_id',    value: 424242),
#    OpenStruct.new(class_name: 'Charge',                      key: 'charge_amount',      value: 42.42),
#    # OpenStruct.new(class_name: 'Document',         key: 'doc_type',           value: 'foobarbaz'),
#    # OpenStruct.new(class_name: 'DocumentGrouping', key: 'service_request_id', value: 424242),
#    OpenStruct.new(class_name: 'ExcludedFundingSource',       key: 'subsidy_map_id',     value: 424242),
#    OpenStruct.new(class_name: 'Fulfillment',                 key: 'date',               value: Date.parse('1914-08-01')),
#    OpenStruct.new(class_name: 'HumanSubjectsInfo',           key: 'submission_type',    value: 'foobarbaz'),
#    OpenStruct.new(class_name: 'Identity',                    key: 'email',              value: 'foo@bar.baz'),
#    OpenStruct.new(class_name: 'ImpactArea',                  key: 'name',               value: 'hi funny people'),
#    OpenStruct.new(class_name: 'InvestigationalProductsInfo', key: 'ind_number',         value: 4242),
#    OpenStruct.new(class_name: 'LineItem',                    key: 'quantity',           value: 42_000_000_000),
#    OpenStruct.new(class_name: 'PastStatus',                  key: 'date',               value: Date.parse('1914-08-01')),
#    OpenStruct.new(class_name: 'PricingMap',                  key: 'full_rate',          value: 0.42),
#    OpenStruct.new(class_name: 'PricingSetup',                key: 'college_rate_type',  value: 'hahaha'),
#    OpenStruct.new(class_name: 'ProjectRole',                 key: 'subspecialty',       value: 'awesomness'),
#    OpenStruct.new(class_name: 'Service',                     key: 'description',        value: 'some useless service'),
#    OpenStruct.new(class_name: 'ServiceProvider',             key: 'organization_id',    value: 424242),
#    OpenStruct.new(class_name: 'ServiceRelation',             key: 'related_service_id', value: 424242),
#    OpenStruct.new(class_name: 'ServiceRequest',              key: 'start_date',         value: Date.parse('1914-08-01')),
#    OpenStruct.new(class_name: 'StudyType',                   key: 'name',               value: 'imaginary_science'),
#    OpenStruct.new(class_name: 'SubServiceRequest',           key: 'status_date',        value: Date.parse('1914-08-01')),
#    OpenStruct.new(class_name: 'SubmissionEmail',             key: 'email',              value: 'billg@microsoft.com'),
#    OpenStruct.new(class_name: 'Subsidy',                     key: 'organization_id',    value: 424242),
#    OpenStruct.new(class_name: 'SubsidyMap',                  key: 'max_percentage',     value: 0.42),
#    OpenStruct.new(class_name: 'SuperUser',                   key: 'organization_id',    value: 424242),
#    OpenStruct.new(class_name: 'Token',                       key: 'token',              value: 'token black student'),
#    OpenStruct.new(class_name: 'VertebrateAnimalsInfo',       key: 'iacuc_number',       value: 4242),
#    OpenStruct.new(class_name: 'Visit',                       key: 'quantity',           value: 2**1024),
#
#    OpenStruct.new(class_name: 'Organization',                key: 'name',               value: 'my useless organization'),
#    OpenStruct.new(class_name: 'Core',                        key: 'name',               value: 'my useless organization'),
#    OpenStruct.new(class_name: 'Program',                     key: 'name',               value: 'my useless organization'),
#    OpenStruct.new(class_name: 'Provider',                    key: 'name',               value: 'my useless organization'),
#    OpenStruct.new(class_name: 'Institution',                 key: 'name',               value: 'my useless organization'),
#
#    OpenStruct.new(class_name: 'Protocol',                    key: 'title',              value: 'my useless project'),
#    # OpenStruct.new(class_name: 'Project',                     key: 'title',              value: 'my useless project'),
#    OpenStruct.new(class_name: 'Study',                       key: 'title',              value: 'my useless project'),
#  ]
  to_test = []

  to_test.each do |entity|
    describe entity.class_name do
      it 'should be possible to go back to a previous version' do
        attrs = FactoryGirl.attributes_for(entity.class_name.underscore.to_sym)
        record = entity.class_name.constantize.new(attrs)
        record.save!(:validate => false)
        orig_value = record[entity.key]

        record[entity.key] = entity.value
        record.save!(:validate => false)
        record[entity.key].should eq entity.value

        record = record.previous_version
        record.save!(:validate => false)
        record[entity.key].should eq orig_value
      end
    end
  end
end

