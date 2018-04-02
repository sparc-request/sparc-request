class RemoveVersion0Surveys < ActiveRecord::Migration[5.1]
  def change
    Survey.all.unscoped.order(:access_code, version: :desc).each do |survey|
      if Survey.where(access_code: survey.access_code).minimum(:version) == 0
        survey.update_attribute(:version, survey.version + 1)
      end
    end
  end
end
