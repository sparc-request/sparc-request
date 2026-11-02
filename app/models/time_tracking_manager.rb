class TimeTrackingManager < ApplicationRecord
  audited

  belongs_to :organization
  belongs_to :identity

  validates :identity_id, uniqueness: { scope: :organization_id }
end
