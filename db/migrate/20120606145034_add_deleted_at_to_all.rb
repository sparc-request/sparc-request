class AddDeletedAtToAll < ActiveRecord::Migration
  def change
    add_column :affiliations                   , :deleted_at  , :datetime
    add_column :approvals                      , :deleted_at  , :datetime
    add_column :catalog_managers               , :deleted_at  , :datetime
    add_column :charges                        , :deleted_at  , :datetime
    add_column :excluded_funding_sources       , :deleted_at  , :datetime
    add_column :fulfillments                   , :deleted_at  , :datetime
    add_column :human_subjects_info            , :deleted_at  , :datetime
    add_column :identities                     , :deleted_at  , :datetime
    add_column :impact_areas                   , :deleted_at  , :datetime
    add_column :investigational_products_info  , :deleted_at  , :datetime
    add_column :ip_patents_info                , :deleted_at  , :datetime
    add_column :line_items                     , :deleted_at  , :datetime
    add_column :organizations                  , :deleted_at  , :datetime
    add_column :past_statuses                  , :deleted_at  , :datetime
    add_column :pricing_maps                   , :deleted_at  , :datetime
    add_column :project_roles                  , :deleted_at  , :datetime
    add_column :protocols                      , :deleted_at  , :datetime
    add_column :research_types_info            , :deleted_at  , :datetime
    add_column :service_relations              , :deleted_at  , :datetime
    add_column :service_requests               , :deleted_at  , :datetime
    add_column :services                       , :deleted_at  , :datetime
    add_column :study_types                    , :deleted_at  , :datetime
    add_column :sub_service_requests           , :deleted_at  , :datetime
    add_column :submission_emails              , :deleted_at  , :datetime
    add_column :subsidies                      , :deleted_at  , :datetime
    add_column :subsidy_maps                   , :deleted_at  , :datetime
    add_column :super_users                    , :deleted_at  , :datetime
    add_column :tokens                         , :deleted_at  , :datetime
    add_column :vertebrate_animals_info        , :deleted_at  , :datetime
    add_column :visits                         , :deleted_at  , :datetime
  end
end
