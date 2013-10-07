class AddTagToPftCore < ActiveRecord::Migration
  def change
    Organization.all.each do |org|
      if org.abbreviation == "PFT Services"
        org.tag_list.add("pft")
        org.save
      end
    end
  end
end
