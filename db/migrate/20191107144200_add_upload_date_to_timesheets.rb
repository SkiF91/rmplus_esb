class AddUploadDateToTimesheets < ActiveRecord::Migration[5.2]
  def change
    add_column :resb_timesheets, :upload_date, :datetime
  end
end