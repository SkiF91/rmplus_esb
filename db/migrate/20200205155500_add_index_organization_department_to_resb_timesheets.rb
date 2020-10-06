class AddIndexOrganizationDepartmentToResbTimesheets < ActiveRecord::Migration[5.2]
  def up
    remove_index :resb_timesheets, [:counting_guid, :date]
    add_index :resb_timesheets, [:counting_guid, :date, :organization_department_guid], name: 'resb_counting_guid_date_department_uniq', unique: true
    add_index :resb_timesheets, [:counting_guid, :date], name: 'resb_counting_guid_date'
  end

  def down
    remove_index :resb_timesheets, [:counting_guid, :date, :organization_department_guid]
    remove_index :resb_timesheets, [:counting_guid, :date]
    add_index :resb_timesheets, [:counting_guid, :date], name: 'resb_counting_guid_date_uniq', unique: true
  end
end