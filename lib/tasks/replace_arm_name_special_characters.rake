namespace :data do
  task replace_arm_name_special_characters: :environment do

    regex = /[[\]][\[][\\]()*\/?:]/

    Arm.all.each do |arm|
      match = arm.name =~ regex
      unless match.nil?
        arm.update_attribute(:name, arm.name.gsub(regex, ' '))
      end
    end
  end
end
