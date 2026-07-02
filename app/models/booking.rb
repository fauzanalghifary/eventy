class Booking < ApplicationRecord
  belongs_to :event

  has_many :booking_items, dependent: :destroy

  validates :booking_date, presence: true
  validates :confirmation_code, presence: true, uniqueness: true
end
