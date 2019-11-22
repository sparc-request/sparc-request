# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class PagesController < ApplicationController
  def event_details
    respond_to :js

    get_calendar_events

    @event = @events.detect{ |event| event[:index] == params[:index].to_i }
  end

  def faqs
    respond_to :js
  end

  def get_news_feed
    respond_to :html

    if Setting.get_value("use_news_feed")
      @news =
        if Setting.get_value("use_news_feed_api")
          NewsFeed.const_get("#{Setting.get_value("news_feed_api")}Adapter").new.posts
        else
          @news = NewsFeed::PageParser.new.posts
        end

      render partial: 'layouts/news'
    end
  end

  def get_calendar_events
    respond_to :html

    if Setting.get_value("use_google_calendar")
      begin
        @events = GoogleCalendarImporter.new.events

        Alert.where(alert_type: ALERT_TYPES['google_calendar'], status: ALERT_STATUSES['active']).update_all(status: ALERT_STATUSES['clear'])
      rescue Exception, ArgumentError => e
        @events = []

        active_alert = Alert.where(alert_type: ALERT_TYPES['google_calendar'], status: ALERT_STATUSES['active']).first_or_initialize
        if Rails.env == 'production' && active_alert.new_record?
          active_alert.save
          ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver unless request.remote_ip == '128.23.150.107' # this is an ignored IP address, MUSC security causes issues when they pressure test,  this should be extracted/configurable
        end
      end

      render partial: 'layouts/events'
    end
  end
end
