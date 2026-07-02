class Event < ApplicationRecord
  belongs_to :venue

  has_many :ticket_types, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :name, presence: true
end
