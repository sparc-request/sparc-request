class AddShortInteractionPermissibleValues < ActiveRecord::Migration[5.2]
  def change
    ## add 3 interaction type: email, in-person, telephone ##
    unless PermissibleValue.where(category: 'interaction_type').exists?
      PermissibleValue.create(category: 'interaction_type', key: 'email', value: 'Email', sort_order: 1, is_available: true)
      PermissibleValue.create(category: 'interaction_type', key: 'in_person', value: 'In-Person', sort_order: 2, is_available: true)
      PermissibleValue.create(category: 'interaction_type', key: 'phone', value: 'Telephone', sort_order: 3, is_available: true)
    end

    ## add interaction subject - expand the list as you wish! ##
    unless PermissibleValue.where(category: 'interaction_subject').exists?
      PermissibleValue.create(category: 'interaction_subject', key: 'general_question', value: 'General Question', is_available: true) 
    end

    ## move institutions from constant.yml to permissible_values
    unless PermissibleValue.where(category: 'institution').exists?
      INSTITUTIONS.each do |name, key|
        PermissibleValue.create(category: 'institution', key: key, value: name, is_available: true)
      end
    end
  end
end
