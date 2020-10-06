class CreateResbPaySheets < ActiveRecord::Migration[4.2]
  def change
    create_table :resb_pay_sheets do |t|
      t.string :loginAD
      t.date :paySheetPeriod
      t.integer :user_id
      t.timestamps
    end
    add_index :resb_pay_sheets, [:user_id], unique: false

  end
end