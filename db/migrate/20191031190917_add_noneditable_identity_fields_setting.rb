class AddNoneditableIdentityFieldsSetting < ActiveRecord::Migration[5.2]
  def change
    unless Setting.find_by_key('noneditable_identity_fields')
      Setting.create(
        key:           'noneditable_identity_fields',
        value:         '["last_name", "first_name", "email"]',
        data_type:     'json',
        friendly_name: 'noneditable user profile fields',
        description:   'Determines which identity fields are read-only on the edit profile page, currently only email, first_name, and last_name are configurable.',
        parent_key:    '',
        parent_value:  ''
      )
    end
  end
end
