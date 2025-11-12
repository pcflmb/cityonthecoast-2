# typed: true

module Api
  class EventsController < ApplicationController
    allow_unauthenticated_access

    # GET /api/events.json
    def index
      events = Event.published.includes(:event_times)

      render json: {
        events: events.sort_by(&:earliest_start).map(&:to_json_api)
      }
    end

    # GET /api/events/:id.json
    def show
      event = Event.published.find(params[:id])
      render json: event.to_json_api
    end
  end
end
