# typed: true

module Admin
  class EventsController < AdminController
    before_action :set_event, only: [:show, :edit, :update, :destroy, :versions, :revert]

    def index
      @events = Event.includes(:event_times).sort_by(&:earliest_start)
    end

    def show
      @versions = @event.event_versions.recent.limit(10)
    end

    def new
      @event = Event.new
      @event.event_times.build # Start with one time slot
    end

    def create
      @event = Event.new(event_params)

      if @event.save
        redirect_to admin_event_path(@event), notice: 'Event created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # Ensure at least one event_time for the form
      @event.event_times.build if @event.event_times.empty?
    end

    def update
      if @event.update(event_params)
        redirect_to admin_event_path(@event), notice: 'Event updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @event.destroy
      redirect_to admin_events_path, notice: 'Event deleted successfully.'
    end

    def versions
      @versions = @event.event_versions.recent.page(params[:page]).per(20)
    end

    def revert
      version_id = params[:version_id]

      if @event.revert_to_version(version_id)
        redirect_to admin_event_path(@event), notice: 'Event reverted successfully.'
      else
        redirect_to versions_admin_event_path(@event), alert: 'Failed to revert event.'
      end
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(
        :name,
        :location,
        :description,
        :image_url,
        :registration_link,
        :published,
        event_times_attributes: [:id, :start_time, :end_time, :position, :_destroy]
      )
    end
  end
end
