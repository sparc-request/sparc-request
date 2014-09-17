module SurveyorHelper
  include Surveyor::Helpers::SurveyorHelperMethods
  
  # helper methods
  def next_section
    # use copy in memory instead of making extra db calls
    next_index = [(@sections.index(@section) || @sections.count) + 1, @sections.count].min
#    @sections.last == @section ? submit_tag(t('surveyor.click_here_to_finish').html_safe, :name => "finish", :class => "btn btn-default btn-lg") : submit_tag(t('surveyor.next_section').html_safe, :name => "section[#{@sections[@sections.index(@section)+1].id}]")
    @sections.last == @section ? submit_tag(t('surveyor.click_here_to_finish').html_safe, :name => "finish", :class => "btn btn-default btn-lg") : submit_tag(t('surveyor.next_section').html_safe, :name => "section[#{@sections[next_index].id}]", :class => "btn btn-default btn-lg")
  end
end
