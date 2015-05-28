class ServiceLevelComponent < ActiveRecord::Base

  include RemotelyNotifiable

  belongs_to :service, counter_cache: true

  attr_accessible :component,
                  :position,
                  :service_id

  validates :component,
            :position,
            presence: true

  private

  def notify_remote_after_create?
    false
  end

  def notify_remote_around_update?
    true
  end

  def notify_remote_after_destroy?
    true
  end
end
