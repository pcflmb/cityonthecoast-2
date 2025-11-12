# typed: true

class Event < ApplicationRecord
  has_many :event_times, -> { order(position: :asc) }, dependent: :destroy
  has_many :event_versions, dependent: :destroy

  accepts_nested_attributes_for :event_times, allow_destroy: true

  validates :name, presence: true
  validates :location, presence: true
  validates :event_times, presence: true

  scope :published, -> { where(published: true) }

  after_save :create_version_snapshot
  before_destroy :create_deletion_snapshot

  sig { returns(ActiveSupport::TimeWithZone) }
  def earliest_start
    T.must(event_times.map(&:start_time).min)
  end

  sig { returns(T::Hash[Symbol, T.any(T.nilable(String), T::Hash[Symbol, T.nilable(String)])]) }
  def to_json_api
    {
      id: id.to_s,
      name: name,
      location: location,
      description: ApplicationHelper.markdown(description) || "",
      image: image_url,
      registrationLink: registration_link,
      event_times: event_times.map do |et|
        {
          start: et.start_time.iso8601,
          end: et.end_time&.iso8601
        }.compact
      end
    }
  end

  sig { params(version_id: String).returns(T::Boolean) }
  def revert_to_version(version_id)
    version = T.let(event_versions.find(version_id), T.nilable(EventVersion))
    return false unless version

    transaction do
      update!(
        name: version.event_name,
        location: version.event_location,
        description: version.event_description,
        image_url: version.event_image_url,
        registration_link: version.event_registration_link
      )

      # Restore event times
      event_times.destroy_all
      version.event_times_snapshot.each_with_index do |time_data, index|
        event_times.create!(
          start_time: time_data['start'],
          end_time: time_data['end'],
          position: index
        )
      end

      # Create version record for the revert
      create_version_snapshot('revert', "Reverted to version from #{version.version_timestamp}")
    end

    true
  end

  private

  def create_version_snapshot(action = 'update', summary = nil)
    event_versions.create!(
      event_name: name,
      event_location: location,
      event_description: description,
      event_image_url: image_url,
      event_registration_link: registration_link,
      event_times_snapshot: event_times.map { |et|
        { start: et.start_time, end: et.end_time }.compact
      },
      action_type: action,
      changed_by: Current.user&.email_address || 'unknown',
      change_summary: summary || generate_change_summary,
      version_timestamp: Time.current
    )
  end

  def create_deletion_snapshot
    create_version_snapshot('delete', 'Event deleted')
  end

  def generate_change_summary
    return 'Event created' if created_at == updated_at

    changes_list = []
    saved_changes.each do |field, (old_val, new_val)|
      next if field.in?(['updated_at', 'created_at'])
      changes_list << "#{field.humanize}: #{old_val} → #{new_val}"
    end

    changes_list.join(', ') if changes_list.any?
  end
end
