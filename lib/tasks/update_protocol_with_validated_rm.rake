require 'progress_bar'

desc 'Updating Protocol with validated Research Master information'
namespace :data do
  task update_protocol_with_validated_rm: :environment do
    print('Fetching from Research Master API...')
    validated_research_masters = HTTParty.get(
      "#{RESEARCH_MASTER_API}validated_records.json",
      headers:{
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=\"#{RMID_API_TOKEN}\""
      }
    )
    puts 'Done'

    puts("\n\nBeginning data refresh...")
    puts(
      "Total number of validated Research Masters from RM API:
      #{validated_research_masters.count}"
    )

    progress_bar = ProgressBar.new(validated_research_masters.count)

    validated_research_masters.each do |vrm|
      if Protocol.exists?(research_master_id: vrm['id'])
        protocol_to_update = Protocol.find_by(research_master_id: vrm['id'])
        protocol_to_update.update_attributes(
          short_title: vrm['short_title'],
          title: vrm['long_title'],
          rmid_validated: true
        )
      end
      progress_bar.increment!
    end
  end
end

