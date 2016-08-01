# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class RemoteServiceNotifierJob < Struct.new(:object_id, :object_class, :action)

  class RemoteServiceNotifierError < StandardError
  end

  def self.enqueue(object_id, object_class, action)
    job = new(object_id, object_class, action)

    Delayed::Job.enqueue job, queue: 'remote_service_notifier'
  end

  def perform
    RestClient.post(url, params, content_type: 'application/json') { |response, request, result, &block|
      unless response.code == 201
        raise RemoteServiceNotifierError
      end
    }
  end

  private

  def url
    [
      REMOTE_SERVICE_NOTIFIER_PROTOCOL,
      '://',
      REMOTE_SERVICE_NOTIFIER_USERNAME,
      ':',
      REMOTE_SERVICE_NOTIFIER_PASSWORD,
      '@',
      REMOTE_SERVICE_NOTIFIER_HOST,
      REMOTE_SERVICE_NOTIFIER_PATH
    ].join
  end

  def params
    {
      notification: {
        sparc_id: object.id,
        kind: object.class.to_s,
        action: action,
        callback_url: object.remote_service_callback_url
      }
    }
  end

  def object
    @object ||= object_class.constantize.find object_id
  end
end
