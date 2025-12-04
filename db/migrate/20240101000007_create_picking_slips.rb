class CreatePickingSlips < ActiveRecord::Migration[7.1]
  def change
    create_table :picking_slips do |t|
      t.references :order, null: false, foreign_key: true
      t.references :printer, foreign_key: true
      t.string :slip_number, null: false, index: { unique: true }
      t.string :status, default: 'pending' # pending, printed, failed
      t.text :slip_content
      t.integer :print_attempts, default: 0
      t.datetime :printed_at
      t.text :error_message
      t.timestamps
    end
  end
end


