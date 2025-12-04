class CreateApiLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :api_logs do |t|
      t.references :order, foreign_key: true
      t.string :api_type, null: false # 'customer_order', 'robot_pick', 'printer'
      t.string :endpoint
      t.string :method, default: 'POST'
      t.jsonb :request_data
      t.jsonb :response_data
      t.integer :status_code
      t.string :status, default: 'pending' # pending, success, failed
      t.text :error_message
      t.datetime :sent_at
      t.timestamps
    end
    
    add_index :api_logs, [:order_id, :api_type]
    add_index :api_logs, :status
  end
end


