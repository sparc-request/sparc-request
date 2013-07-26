survey "System Satisfaction survey", :default_mandatory => false do
  section "System Satisfaction" do
    question_1 "1) Are you satisfied with your use of SPARC Request <span class='underline'>today</span>?", :pick => :one
    answer_yes "Yes"
    answer_no "No"

    question "If yes, please tell us why. (Intuitive? User Friendly? Other? Have suggestions for us?)"
    answer :text
    dependency :rule => "Y"
    condition_Y :question_1, "==", :answer_yes
    
    question "If no, please tell us why. (Have suggestions for us to make it better?)"
    answer :text
    dependency :rule => "N"
    condition_N :question_1, "==", :answer_no
  end
end
