class AddFundingConfigurationsToSettings < ActiveRecord::Migration[5.1]
  def change
    unless Setting.where(key: 'funding_admins').any?
      funding_admins = Setting.create(
        key:           'funding_admins',
        value:         '[]',
        data_type:     'json',
        friendly_name: 'Funding Admins',
        description:   '(Array of ldap_uid) Determines which users will have access to the SPARCFunding module.',
        parent_key:    '',
        parent_value:  ''
      )
    end

    unless Setting.where(key: 'funding_org_ids').any?
      funding_org_ids = Setting.create(
        key:           'funding_org_ids',
        value:         '[]',
        data_type:     'json',
        friendly_name: 'Funding Organizations IDs',
        description:   '(Array of organization ids) Determines whether an organization lists funding opportunities as SPARC services.',
        parent_key:    '',
        parent_value:  ''
      )
    end
  end
end
