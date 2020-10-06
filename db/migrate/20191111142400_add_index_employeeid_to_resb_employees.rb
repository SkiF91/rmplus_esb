class AddIndexEmployeeidToResbEmployees < ActiveRecord::Migration[5.2]
  def change
    add_index :resb_employees, :employeeId, unique: false
  end
end