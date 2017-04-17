task clean_up_duplicate_org: :environment do
  org = Organization.find(60)

  org.services.destroy_all

  Service.find(484).update_attributes(organization: org)

  Service.find(485).update_attributes(organization: org)
end
