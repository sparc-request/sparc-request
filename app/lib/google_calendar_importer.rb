# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class GoogleCalendarImporter
  include ActionView::Helpers::TextHelper

  def initialize
    curTime   = Time.now.utc
    @startMin = curTime
    @startMax = (curTime + 1.month)
    @cal      = Icalendar::Calendar.parse(open(Setting.get_value("calendar_url")).read).first
  end

  def events
    events = []

    # Use index like an ID to view more information
    index = 0
    @cal.events.each do |event|
      if event.occurrences_between(@startMin, @startMax).present?
        event.occurrences_between(@startMin, @startMax).each do |occurrence|
          events << create_calendar_event(event, occurrence, index)
          index += 1
        end
      end
    end

    events.sort_by{ |e| e[:sort_by_start].to_i }.reverse!
  end

  private

  def create_calendar_event(event, occurrence, index)
    all_day     = !occurrence.start_time.to_s.include?("UTC")
    start_time  = DateTime.parse(occurrence.start_time.to_s).in_time_zone("Eastern Time (US & Canada)")
    end_time    = DateTime.parse(occurrence.end_time.to_s).in_time_zone("Eastern Time (US & Canada)")
    {
      index:          index,
      title:          event.summary,
      description:    simple_format(event.description).gsub(URI::regexp(%w(http https)), '<a href="\0" target="blank">\0</a>'),
      date:           start_time.strftime("%A, %B %d"),
      time:           all_day ? t('layout.navigation.events.all_day') : [start_time.strftime("%l:%M %p"), end_time.strftime("%l:%M %p")].join(' - '),
      where:          event.location,
      month:          start_time.strftime("%b"),
      day:            start_time.day,
      sort_by_start:  start_time.strftime("%Y%m%d")
    }
  end
end
