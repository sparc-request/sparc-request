module Portal::EpicQueuesHelper

  def format_protocol(protocol)
    "#{protocol.type.capitalize}: #{protocol.id} - #{protocol.short_title}"
  end

  def format_date(protocol)
    date = protocol.last_epic_push_time
    puts "*" * 50
    puts date
    if date.present?
      date.strftime(t(:epic_queues)[:date_formatter])
    else
      ''
    end
  end

  def format_status(protocol)
    status = protocol.last_epic_push_status
    if status.present?
      "#{status.capitalize}"
    else
      ''
    end
  end
end
