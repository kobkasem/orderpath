class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :api_key, null: false, index: { unique: true }
      t.string :api_endpoint, null: false
      t.boolean :active, default: true
      t.jsonb :api_config, default: {}
      t.timestamps
    end
  end
end


