class AddManagersGuidToDepartment < ActiveRecord::Migration[5.2]
  def change
    add_column :resb_organization_departments, :manager_guid, :string
    add_column :resb_organization_departments, :acting_manager_guid, :string
  end
end