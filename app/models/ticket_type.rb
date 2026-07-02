class TicketType < ApplicationRecord
  belongs_to :event

  has_many :booking_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }

  def self.booked_quantities_on(ticket_type_ids:, booking_date:)
    BookingItem
      .joins(:booking)
      .where(ticket_type_id: ticket_type_ids)
      .where(bookings: { booking_date: booking_date })
      .group(:ticket_type_id)
      .sum(:quantity)
  end

  def booked_quantity_on(booking_date)
    self.class.booked_quantities_on(
      ticket_type_ids: [id],
      booking_date: booking_date
    ).fetch(id, 0)
  end

  def remaining_capacity_on(booking_date)
    capacity - booked_quantity_on(booking_date)
  end
end
