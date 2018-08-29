class AddTableauEmbedSettings < ActiveRecord::Migration[5.1]
  def up
    unless Setting.find_by_key('use_tableau')
      Setting.create(
        key: 'use_tableau',
        value: true,
        data_type: 'boolean',
        friendly_name: 'Use Tableau',
        description: 'Determines whether the application will integrate with Tableau.'
      )
    end

    unless Setting.find_by_key('homepage_tableau_url')
      Setting.new(
        key: 'homepage_tableau_url',
        value: "https://anyl-tableau-v.mdc.musc.edu/javascripts/api/viz_v1.js",
        data_type: 'url',
        friendly_name: 'Homepage Tableau Url',
        description: 'The URL of the Tableau server used to embed a dashboard on the SPARCRequest homepage.',
        parent_key: 'use_tableau',
        parent_value: 'true'
      ).save(validate: false)
    end

    unless Setting.find_by_key('homepage_tableau_dashboard')
      Setting.new(
        key: 'homepage_tableau_dashboard',
        value: "InstitutionalDashboard/RadialTreeDashboard",
        data_type: 'string',
        friendly_name: 'Homepage Tableau Dashboard',
        description: 'The name of the dashboard to be embedded on the SPARCRequest homepage.',
        parent_key: 'use_tableau',
        parent_value: 'true'
      ).save(validate: false)
    end
  end

  def down
    Setting.find_by_key('use_tableau').try(:destroy)
    Setting.find_by_key('homepage_tableau_url').try(:destroy)
    Setting.find_by_key('homepage_tableau_dashboard').try(:destroy)
  end
end
