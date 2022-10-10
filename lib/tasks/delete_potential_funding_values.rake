desc "Delete potential funding permissible values"
task delete_potential_funding_values: :environment do

  values = PermissibleValue.where(category: "potential_funding_source")

  values.each do |value|
    value.destroy
  end
end