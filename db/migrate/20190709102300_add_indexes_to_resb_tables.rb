class AddIndexesToResbTables < ActiveRecord::Migration[5.2]
  def change
    add_index :resb_employees_1c, [:counting_guid]
    add_index :resb_employees_1c, [:employee_id ]
    add_index :resb_organization_departments, [:guid]
    add_index :resb_positions, [:guid]
  end
end