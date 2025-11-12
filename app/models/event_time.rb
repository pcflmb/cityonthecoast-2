# typed: true

class EventTime < ApplicationRecord
  belongs_to :event

  validates :start_time, presence: true
  validate :end_time_after_start_time

  scope :upcoming, -> { where('start_time >= ?', Time.current) }
  scope :past, -> { where('start_time < ?', Time.current) }

  private

  def end_time_after_start_time
    et = end_time
    return if et.blank?

    if et <= start_time
      errors.add(:end_time, 'must be after start time')
    end
  end
end
