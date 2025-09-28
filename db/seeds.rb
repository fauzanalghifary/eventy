# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
Venue.destroy_all

# Create sample venue - Serengeti Park
venue = Venue.create!(name: "Serengeti Park")

puts "Seed data created successfully!"
puts "Created venue: #{venue.name}"
