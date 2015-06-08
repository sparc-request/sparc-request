class ServiceLevelComponent < ActiveRecord::Base

  include RemotelyNotifiable

  belongs_to :service, counter_cache: true

  attr_accessible :component,
                  :position,
                  :service_id

  validates :component,
            :position,
            presence: true

end
