class AddOrganizationDepartmentGuidToResbTimesheets < ActiveRecord::Migration[5.2]
  def change
    add_column :resb_timesheets, :organization_department_guid, :string
    add_column :resb_timesheets, :document_number, :string

    add_index :resb_timesheets, :organization_department_guid, name: 'index_resb_timesheets_organization_department_guid'
    add_index :resb_timesheets, :document_number, name: 'index_resb_timesheets_document_number'
  end
end