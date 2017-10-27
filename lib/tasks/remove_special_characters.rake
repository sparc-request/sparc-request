namespace :data do
  task remove_special_characters: :environment do

    puts "Removing special characters from Protocol titles..."

    updated_protocols = []

    regex = /^[a-zA-Z0-9!@#\$%\^\&*\)\(+=._-]+$/

    progress_bar = ProgressBar.new(Protocol.all.count)

    Protocol.all.each do |protocol|
      if regex.match?(protocol.short_title)
        protocol.short_title.gsub(/^[a-zA-Z0-9!@#\$%\^\&*\)\(+=._-]+$/, '')
        protocol.save
        updated_protocols << protocol.id
      end

      if regex.match?(protocol.title)
        protocol.title.gsub(/^[a-zA-Z0-9!@#\$%\^\&*\)\(+=._-]+$/, '')
        protocol.save
        updated_protocols << protocol.id
      end
      progress_bar.increment!
    end

    puts "#{updated_protocols.uniq.count} Protocols updated"
    puts "Done"
  end
end

