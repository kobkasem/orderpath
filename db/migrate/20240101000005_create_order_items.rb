class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :sku, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :quantity_from_robot, default: 0
      t.integer :quantity_from_bin, default: 0
      t.string :status, default: 'pending' # pending, allocated, picked, completed
      t.timestamps
    end
  end
end


