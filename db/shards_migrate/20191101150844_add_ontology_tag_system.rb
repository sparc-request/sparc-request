class AddOntologyTagSystem < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    ## Add column to store ontology tag on organization
    add_column :organizations, :ontology_tag, :string
  end
end
