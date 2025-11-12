# typed: true

class EventsController < ApplicationController
  allow_unauthenticated_access

  def index
    @events = Event.published.includes(:event_times).sort_by(&:earliest_start)

    respond_to do |format|
      format.html # Renders the main site
      format.json { render json: { events: @events.map(&:to_json_api) } }
    end
  end

  def show
    @event = Event.published.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @event.to_json_api }
    end
  end
end
