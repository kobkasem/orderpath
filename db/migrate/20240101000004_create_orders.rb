class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :order_number, null: false, index: { unique: true }
      t.string :airway_bill_number
      t.string :status, default: 'pending' # pending, processing, completed, failed
      t.jsonb :order_data, default: {}
      t.text :error_message
      t.integer :retry_count, default: 0
      t.datetime :processed_at
      t.timestamps
    end
    
    add_index :orders, :status
  end
end


