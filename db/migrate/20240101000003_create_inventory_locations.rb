class CreateInventoryLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :inventory_locations do |t|
      t.references :sku, null: false, foreign_key: true
      t.string :location_type, null: false # 'robot' or 'bin'
      t.string :location_code
      t.integer :quantity, default: 0
      t.integer :reserved_quantity, default: 0
      t.timestamps
    end
    
    add_index :inventory_locations, [:sku_id, :location_type]
  end
end


