class FixIsAvailableData < ActiveRecord::Migration[5.2]
  def change
    Organization.where(is_available: true).each do |org|
      if org.parents.detect{|parent| !parent.is_available}
        org.update_attribute(:is_available, false)
        puts "Org ID: #{org.id}, Name: #{org.name} Deactivated"
      end
    end

    Service.where(is_available: true).each do |service|
      if !service.organization.is_available
        service.update_attribute(:is_available, false)
        puts "Service ID: #{service.id}, Name: #{service.name} Deactivated"
      end
    end
  end
end
