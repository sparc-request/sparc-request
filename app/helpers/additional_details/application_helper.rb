module AdditionalDetails::ApplicationHelper

  def convert_time(time)
    DateTime.strptime(time.gsub(':', ''), '%H%M').strftime('%l:%M')
  end
end
