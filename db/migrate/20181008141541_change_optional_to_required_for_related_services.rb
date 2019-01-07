class ChangeOptionalToRequiredForRelatedServices < ActiveRecord::Migration[5.2]
  def change
    ServiceRelation.all.each do |service_relation|
      service_relation.update_attribute(:optional, !service_relation.optional)
    end

    rename_column :service_relations, :optional, :required
  end
end
