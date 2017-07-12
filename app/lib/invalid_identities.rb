class InvalidIdentities

  def initialize(identities)
    @identities = identities
  end

  def remove_from_db
    @identities.each do |identity|
      next if !identity.last_sign_in_at.nil?
      next if identity.project_roles.present?
      next if identity.catalog_managers.present?
      next if identity.clinical_providers.present?
      next if identity.service_providers.present?
      next if identity.super_users.present?
      identity.destroy
    end
    @identities
  end
end

