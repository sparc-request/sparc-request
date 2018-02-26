class GeneralizeQuestionnaire < ActiveRecord::Migration[5.1]
  class Questionnaire < ApplicationRecord
  end
  
  def change
    add_reference :questionnaires, :questionable, polymorphic: true
    Questionnaire.find_each do |q|
      q.update( questionable_id: q.service_id, questionable_type: 'Service')
    end
    remove_reference :questionnaires, :service, index: true, foreign_key: true
  end
end
