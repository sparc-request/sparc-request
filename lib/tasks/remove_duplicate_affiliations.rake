desc "Remove duplicate affiliations"
task remove_duplicate_affiliations: :environment do

  duplicate_affiliations = Affiliation.all.group_by{ |a| [a.protocol_id, a.name] }.select{ |k, v| v.size > 1}.values
  fixed_array = []
  duplicate_affiliations.each do |aff_array|
    fixed_array << aff_array[0].protocol_id

    aff_array.shift
    aff_array.each(&:destroy)
  end
   
  puts 'The following protocols were fixed: '
  fixed_array.uniq.each do |id|
    puts id
  end
end