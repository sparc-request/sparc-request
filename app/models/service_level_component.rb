class ServiceLevelComponent < ActiveRecord::Base

  belongs_to :service, counter_cache: true

  attr_accessible :component,
                  :position,
                  :service_id

  validates :component,
            :position,
            :service_id,
            presence: true

end
