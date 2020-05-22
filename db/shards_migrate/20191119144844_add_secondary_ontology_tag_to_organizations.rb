class AddSecondaryOntologyTagToOrganizations < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    ## Add secondary ontology tag on organization
    add_column :organizations, :secondary_ontology_tag, :string

    ## Rename ontology tag to primary ontology tag
    rename_column :organizations, :ontology_tag, :primary_ontology_tag
  end
end
