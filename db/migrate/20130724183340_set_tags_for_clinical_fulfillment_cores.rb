class SetTagsForClinicalFulfillmentCores < ActiveRecord::Migration
  def up
    Organization.all.each do |org|
      if org.abbreviation == "Nutrition"
        org.tag_list.add("nutrition")
        org.save
      elsif org.abbreviation == "Nursing"
      	org.tag_list.add("nursing")
        org.save
      elsif org.abbreviation == "Imaging"
      	org.tag_list.add("imaging")
        org.save
      elsif org.abbreviation == "Lab and Biorepistory"
      	org.tag_list.add("laboratory")
      	org.save
      end      
    end
  end

  def down
    Organization.all.each do |org|
      if org.abbreviation == "Nutrition"
        org.tag_list = ""
        org.save
      elsif org.abbreviation == "Nursing"
      	org.tag_list = ""
        org.save
      elsif org.abbreviation == "Imaging"
      	org.tag_list = ""
        org.save
      elsif org.abbreviation == "Lab and Biorepistory"
       	org.tag_list = ""
      	org.save
      end 
    end
  end
end
