class CreateEsbTables < ActiveRecord::Migration[4.2]
  def change
    create_table :resb_log do |t|
      t.integer :code, null: false
      t.text :message
      t.timestamps
    end
    add_index :resb_log, [:code], unique: false

    create_table :resb_trade_points do |t|
      t.string :name
      t.integer :foreign_id
      t.boolean :deleted
      t.integer :storage_code
      t.integer :region_code
      t.string :address
      t.integer :city_id
      t.integer :department_id
      t.timestamps
    end

    add_index :resb_trade_points, [:foreign_id], unique: true
  end
end