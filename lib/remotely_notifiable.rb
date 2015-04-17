module RemotelyNotifiable

  extend ActiveSupport::Concern

  included do
    after_create  :notify_remote_after_create,  if: :notify_remote_after_create?
    around_update :notify_remote_around_update, if: :notify_remote_around_update?
    after_destroy :notify_remote_after_destroy, if: :notify_remote_after_destroy?
  end

  def remote_service_callback_url
    if self.persisted?
      "#{REMOTE_SERVICE_NOTIFIER_PROTOCOL}://#{HOST}/#{CURRENT_API_VERSION}/#{self.class.to_s.pluralize.underscore}/#{self.id}.json"
    end
  end

  private

  # Default to false
  def notify_remote_after_create?
    false
  end

  # Default to false
  def notify_remote_around_update?
    false
  end

  # Default to false
  def notify_remote_after_destroy?
    false
  end

  # Default to all attributes
  def remotely_notifiable_attributes_to_watch
    attributes.keys
  end

  def notify_remote_after_create
    RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'create')
  end

  def detected_changes
    remotely_notifiable_attributes_to_watch & changed
  end

  def notify_remote_around_update
    remotely_notifiable_attributes_changed = detected_changes.any?

    yield

    if remotely_notifiable_attributes_changed
      RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'update')
    end
  end

  def notify_remote_after_destroy
    RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'destroy')
  end
end
