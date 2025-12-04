class CreateSkus < ActiveRecord::Migration[7.1]
  def change
    create_table :skus do |t|
      t.string :sku_code, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :category, null: false
      t.string :model
      t.integer :robot_threshold, default: 5
      t.boolean :active, default: true
      t.timestamps
    end
  end
end


