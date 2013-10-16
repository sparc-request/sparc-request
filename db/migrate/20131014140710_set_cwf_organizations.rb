class SetCwfOrganizations < ActiveRecord::Migration
  def up
    Organization.all.each do |org|
      if org.abbreviation == "Nutrition"
        org.position_in_cwf = 4
        org.show_in_cwf = true
        org.save
      elsif org.abbreviation == "Nursing"
        org.position_in_cwf = 1
        org.show_in_cwf = true
        org.save
      elsif org.abbreviation == "Imaging"
        org.position_in_cwf = 3
        org.show_in_cwf = true
        org.save
      elsif org.abbreviation == "Lab and Biorepistory"
        org.position_in_cwf = 2
        org.show_in_cwf = true
        org.save
      elsif org.abbreviation == "PFT Services"
        org.position_in_cwf = 5
        org.show_in_cwf = true
        org.save
      end
    end
  end

  def down
    Organization.all.each do |org|
      if org.abbreviation == "Nutrition"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      elsif org.abbreviation == "Nursing"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      elsif org.abbreviation == "Imaging"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      elsif org.abbreviation == "Lab and Biorepistory"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      elsif org.abbreviation == "PFT Services"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      end
    end
  end
end
