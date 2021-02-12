class FulfillmentSynchronization < ApplicationRecord
  audited

  belongs_to :sub_service_request

  scope :unsynced, -> { where(synched: false) }
end
