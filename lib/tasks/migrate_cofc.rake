desc "Move Cofc Answer"
task :migrate_cofc => :environment do
	protocols = Protocol.all
	protocols.each do |protocol|
		protocol.study_type_answers.each do |answer|
			if (answer.study_type_question.id == 2) && !answer.answer
				puts "Protocol id:  #{protocol.id}"
				puts "Second Question is NOT answered"
				if protocol.has_cofc
					puts "Updated new answer for the protocol"
					answer.update_attributes(answer: true)
					puts "Updated #{answer.inspect}"
				end
			end	
		end
	end
end