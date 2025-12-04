class CreatePickingSlipItems < ActiveRecord::Migration[7.1]
  def change
    create_table :picking_slip_items do |t|
      t.references :picking_slip, null: false, foreign_key: true
      t.references :order_item, null: false, foreign_key: true
      t.string :location_type, null: false # 'bin' or 'robot'
      t.string :location_code
      t.integer :quantity, null: false
      t.integer :sequence, null: false
      t.timestamps
    end
    
    add_index :picking_slip_items, [:picking_slip_id, :sequence]
  end
end


