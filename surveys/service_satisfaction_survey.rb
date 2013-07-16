survey "Service Satisfaction Survey", :default_mandatory => false do
  section "Service Satisfaction" do
    answer_set_one = ['Needs Improvement', 'Fair', 'Good', 'Excellent', 'Outstanding']
    answer_set_two = ['Strongly Disagree', 'Neither Agree nor Disagree', 'Agree', 'Strongly Agree']

    question "The overall quality of services provided", :pick => :one, :display_type => :slider
    answer_set_one.each{|level| answer level}

    question "The services/products provided are priced/valued at a rate better than other institutional and/or outside sources", :pick => :one, :display_type => :slider
    answer_set_two.each{|level| answer level}

    question "Services/products have been available in a timely fashion", :pick => :one, :display_type => :slider
    answer_set_two.each{|level| answer level}

    question "Range/types of services provided are adequate for my research needs", :pick => :one, :display_type => :slider
    answer_set_two.each{|level| answer level}
  end
end
