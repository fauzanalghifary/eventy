class TicketType < ApplicationRecord
  belongs_to :event

  has_many :booking_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }
end
