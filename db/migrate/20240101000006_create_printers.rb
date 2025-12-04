class CreatePrinters < ActiveRecord::Migration[7.1]
  def change
    create_table :printers do |t|
      t.string :name, null: false
      t.string :ip_address, null: false
      t.integer :port, default: 9100
      t.string :printer_type, default: 'picking_slip' # picking_slip, label, etc.
      t.boolean :active, default: true
      t.jsonb :config, default: {}
      t.timestamps
    end
    
    add_index :printers, :ip_address
  end
end


