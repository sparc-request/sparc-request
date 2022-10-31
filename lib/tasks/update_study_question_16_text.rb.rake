task update_study_question_16_text: :environment do
    @study_type_question_16 = StudyTypeQuestion.find(16)
    @study_type_question_16.update(question: "4. Is it appropriate to display the yellow \"Research Participant\" advisory for all study participants?")
end
