module AdditionalDetails::ApplicationHelper

  def convert_time(time)
    modifier = ''
    ((time.first == '0') || (time[0..1] == '10') || (time[0..1] == '11')) ? modifier = ' AM' : modifier = ' PM'

    DateTime.strptime(time.gsub(':', ''), '%H%M').strftime('%l:%M') + modifier
  end
end
