task survey_cleanup: :environment do

  Response.all.each do |response|
    if !response.question_responses.empty?
      content_array = response.question_responses.map(&:content)
      if (content_array.reject(&:blank?).size == 0)
        puts "destroying qrs for response #{response.id}"
        response.question_responses.each do |qr|
          qr.destroy
        end
      end
    end
  end
end