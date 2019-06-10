class EventsController < ApplicationController
  respond_to :js

  before_action :get_calendar_events

  def show
    @event = @events.detect{ |event| event[:index] == params[:index].to_i }
  end
end
