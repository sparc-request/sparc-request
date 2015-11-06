desc "Create an Associated Survey"
task associate_survey: :environment do
  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  org_id = prompt "What is the Organization ID? "
  survey_id = prompt "What is the Survey ID? "
  AssociatedSurvey.create(surveyable_id: org_id, surveyable_type: "Organization", survey_id: survey_id)
  puts "MISSION ACCOMPLISHED."
end
