class CreateResbTimesheets < ActiveRecord::Migration[5.2]
  def change
    create_table :resb_timesheets do |t|
      t.integer :employee_id
      t.boolean :deleted
      t.string :counting_guid
      t.date :date
      t.float :hours
    end

    add_index :resb_timesheets, [:counting_guid, :date], name: 'resb_counting_guid_date_uniq', unique: true
  end
end