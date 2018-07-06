class AddShortInteractionPermissibleValues < ActiveRecord::Migration[5.2]
  def change
    ## add 3 interaction_type pvs: email, in-person, telephone ##
    unless PermissibleValue.where(category: 'interaction_type').exists?
      PermissibleValue.create(category: 'interaction_type', key: 'email', value: 'Email', sort_order: 1)
      PermissibleValue.create(category: 'interaction_type', key: 'in_person', value: 'In-Person', sort_order: 2)
      PermissibleValue.create(category: 'interaction_type', key: 'phone', value: 'Telephone', sort_order: 3)
      PermissibleValue.where(category: 'interaction_type').update_all(is_available: true)
    end

    ## add interaction_subject pvs - add or remove items from the following list as you wish ##
    unless PermissibleValue.where(category: 'interaction_subject').exists?
      PermissibleValue.create(category: 'interaction_subject', key: 'bmi_apps', value: 'Bioinformatics Software Choice, Training and Applications')
      PermissibleValue.create(category: 'interaction_subject', key: 'bmi__study_design', value: 'Bioinformatics Study Design')
      PermissibleValue.create(category: 'interaction_subject', key: 'biostatistical_question', value: 'Biostatistical Question')
      PermissibleValue.create(category: 'interaction_subject', key: 'career_development', value: 'Career Development')
      PermissibleValue.create(category: 'interaction_subject', key: 'funding_opportunities', value: 'Funding Opportunities')
      PermissibleValue.create(category: 'interaction_subject', key: 'general_question', value: 'General Question')
      PermissibleValue.create(category: 'interaction_subject', key: 'redcap', value: 'REDCap')
      PermissibleValue.create(category: 'interaction_subject', key: 'regulatory_question', value: 'Regulatory Question')
      PermissibleValue.where(category: 'interaction_subject').update_all(is_available: true)
    end

    ## move institutions from constant.yml to permissible_values
    unless PermissibleValue.where(category: 'institution').exists?
      INSTITUTIONS.each do |name, key|
        PermissibleValue.create(category: 'institution', key: key, value: name)
      end
      PermissibleValue.where(category: 'institution').update_all(is_available: true)
    end
  end
end
