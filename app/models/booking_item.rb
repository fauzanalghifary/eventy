class BookingItem < ApplicationRecord
  belongs_to :booking
  belongs_to :ticket_type

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validate :ticket_type_belongs_to_booking_event

  private

  def ticket_type_belongs_to_booking_event
    return if booking.blank? || ticket_type.blank?
    return if ticket_type.event == booking.event

    errors.add(:ticket_type, "must belong to the booking event")
  end
end
