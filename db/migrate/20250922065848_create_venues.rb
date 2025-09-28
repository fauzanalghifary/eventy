class CreateVenues < ActiveRecord::Migration[8.0]
  def change
    create_table :venues do |t|
      t.string :name

      t.timestamps
    end
  end
end
