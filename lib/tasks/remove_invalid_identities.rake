namespace :data do
  task remove_invalid_identities: :environment do
    missing_emails = Identity.where(email: nil)
    invalid_identities = InvalidIdentities.new(missing_emails)
    invalid_identities.remove_from_db
  end
end
