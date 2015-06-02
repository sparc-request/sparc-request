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
  def remotely_notifiable_attributes_to_watch_for_change
    attributes.keys
  end

  def notify_remote_after_create
    RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'create')
  end

  def qualifying_changes_detected?
    (remotely_notifiable_attributes_to_watch_for_change & changed).any?
  end

  def notify_remote_around_update
    yield

    if qualifying_changes_detected?
      RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'update')
    end
  end

  def notify_remote_after_destroy
    RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'destroy')
  end
end
