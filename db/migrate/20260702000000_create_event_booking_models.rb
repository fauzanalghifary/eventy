class CreateEventBookingModels < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :venue, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    create_table :ticket_types do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :price_cents, null: false
      t.integer :capacity, null: false

      t.timestamps
    end

    create_table :bookings do |t|
      t.references :event, null: false, foreign_key: true
      t.date :booking_date, null: false
      t.string :confirmation_code, null: false

      t.timestamps
    end

    create_table :booking_items do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :ticket_type, null: false, foreign_key: true
      t.integer :quantity, null: false

      t.timestamps
    end

    add_index :bookings, :confirmation_code, unique: true
    add_index :bookings, [:event_id, :booking_date]
    add_index :booking_items, [:booking_id, :ticket_type_id]
    add_index :ticket_types, [:event_id, :name], unique: true
  end
end
