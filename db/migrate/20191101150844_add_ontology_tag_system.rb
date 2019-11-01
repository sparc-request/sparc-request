class AddOntologyTagSystem < ActiveRecord::Migration[5.2]
  def change
    ## Add column to store ontology tag on organization
    add_column :organizations, :ontology_tag, :string

    ## Populate new ontology tag permissible values
    unless PermissibleValue.where(category: 'ontology_tag').exists?
      PermissibleValue.create(category: 'ontology_tag', key: 'admin_core_ctsa', value: 'Administrative Core (CTSA)', sort_order: 1, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'informatics_ctsa', value: 'Informatics (CTSA)', sort_order: 2, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'community_engagement_ctsa', value: 'Community Engagement (CTSA)', sort_order: 3, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'team_science_ctsa', value: 'Multidisciplinary Team Science (CTSA)', sort_order: 4, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'workforce_ctsa', value: 'Translational Workforce Development (CTSA)', sort_order: 5, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'pilot_ctsa', value: 'Pilot Translational Clinical Studies (CTSA)', sort_order: 6, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'berd_ctsa', value: 'CTSA-Biostatistics, Epidemiology & Research Design (CTSA)', sort_order: 7, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'regulatory_ctsa', value: 'Regulatory Knowledge & Support (CTSA)', sort_order: 8, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'special_population_ctsa', value: 'Integrating Special Populations (CTSA)', sort_order: 9, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'clinical_interaction_ctsa', value: 'Participant & Clinical Interactions (CTSA)', sort_order: 10, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'network_capacity_ctsa', value: 'Network Capacity (CTSA)', sort_order: 11, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'optional_program_ctsa', value: 'Optional Programs (CTSA)', sort_order: 12, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'admin_core_ctr', value: 'Administratiove Core (CTR)', sort_order: 13, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'community_engagement_ctr', value: 'Community Engagement & Outreach (CTR)', sort_order: 14, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'professional_development_ctr', value: 'Professional Development (CTR)', sort_order: 15, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'pilot_ctr', value: 'Pilot Projects Program (CTR)', sort_order: 16, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'berd_ctr', value: 'Biostatistics, Epidemiology & Research Design (CTR)', sort_order: 17, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'evaluation_ctr', value: 'Tracking & Evaluation (CTR)', sort_order: 18, is_available: true)
      PermissibleValue.create(category: 'ontology_tag', key: 'optional_core_ctr', value: 'Optional Core (CTR)', sort_order: 19, is_available: true)
    end
  end
end
