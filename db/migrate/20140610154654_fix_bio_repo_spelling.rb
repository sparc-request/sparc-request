class FixBioRepoSpelling < ActiveRecord::Migration
  def up
    org = Organization.find_by_abbreviation("Lab and Biorepistory")
    org.abbreviation = "Lab and Biorepository"
    org.save
  end

  def down
    org = Organization.find_by_abbreviation("Lab and Biorepository")
    org.abbreviation = "Lab and Biorepistory"
    org.save
  end
end
