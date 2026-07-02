class TicketType < ApplicationRecord
  belongs_to :event

  has_many :booking_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }

  def booked_quantity_on(booking_date)
    booking_items
      .joins(:booking)
      .where(bookings: { booking_date: booking_date })
      .sum(:quantity)
  end

  def remaining_capacity_on(booking_date)
    capacity - booked_quantity_on(booking_date)
  end
end
