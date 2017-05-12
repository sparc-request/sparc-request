module AdditionalDetails::ApplicationHelper

  def convert_time(time)
    DateTime.strptime(time, '%H:%M').strftime('%l:%M %p')
  end
end
