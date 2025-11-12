# typed: true

class EventVersion < ApplicationRecord
  belongs_to :event

  validates :event_name, presence: true
  validates :action_type, inclusion: { in: %w[create update delete revert] }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action_type: action) }

  sig { returns(T.nilable(String)) }
  def formatted_timestamp
    version_timestamp&.strftime('%b %d, %Y at %I:%M %p')
  end

  sig { returns(String) }
  def changes_description
    change_summary || "#{action_type&.humanize || 'unknown action'} by #{changed_by || 'unknown user'}"
  end
end
