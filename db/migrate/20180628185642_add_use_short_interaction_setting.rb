class AddUseShortInteractionSetting < ActiveRecord::Migration[5.2]
  def change
    unless Setting.find_by_key('use_short_interaction')
      Setting.create(
        key:           'use_short_interaction', 
        value:         'false', 
        data_type:     'boolean', 
        friendly_name: 'Use Short Interaction',
        description:   'Determines whether or not the application will use Short Interaction',
        parent_key:    '',
        parent_value:  '')
    end
  end
end
