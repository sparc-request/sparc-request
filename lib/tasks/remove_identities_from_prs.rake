namespace :data do
  task remove_identities_from_prs: :environment do
    ocr_folks = [
      12911,
      17231,
      13829,
      434,
      9594,
      46393,
      23135
    ]
    puts "Found relevant OCR Identities,
    next we'll discover associated Project Roles"

    ocr_prs = ProjectRole.where(identity_id: ocr_folks).where.not(role: 'primary-pi')

    puts "Found Project Roles, removing..."

    ocr_prs.destroy_all

    puts "Project Roles have been removed. Task is complete"
  end
end
