module AdditionalDetails::ApplicationHelper

  def convert_time(time)
    modifier = ''
    time.first == '0' ? modifier = ' AM' : modifier = ' PM'
    # if time.first == '0'
    #   modifier = 'AM'
    # else
    #   modifier = 'PM'
    DateTime.strptime(time.gsub(':', ''), '%H%M').strftime('%l:%M') + modifier
  end
end
