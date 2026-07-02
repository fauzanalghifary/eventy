# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
BookingItem.destroy_all
Booking.destroy_all
TicketType.destroy_all
Event.destroy_all
Venue.destroy_all

# Create sample venue, event, and ticket types from the challenge scenario
venue = Venue.create!(name: "Serengeti Park")
event = venue.events.create!(
  name: "Evening Safari",
  description: "A guided evening tour through Serengeti Park."
)

event.ticket_types.create!([
  { name: "Adult", price_cents: 2_500, capacity: 10 },
  { name: "Child", price_cents: 1_500, capacity: 10 },
  { name: "Member", price_cents: 2_000, capacity: 5 }
])

puts "Seed data created successfully!"
puts "Created venue: #{venue.name}"
puts "Created event: #{event.name}"
puts "Created ticket types: #{event.ticket_types.pluck(:name).join(", ")}"
