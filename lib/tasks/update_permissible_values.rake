desc "Update permissible values reserved attribute"
task update_permissible_values: :environment do

  reserved_categories = [ 'funding_status', 'funding_source', 'proxy_right' ]
  values_grouped_by_category = PermissibleValue.all.group_by(&:category)

  values_grouped_by_category.each do |category, values|
    if reserved_categories.include?(category)
      puts "Updating reserved status of #{category}"
      values.each do |value|
        value.update_attributes(reserved: true)
      end
    end
  end
end

