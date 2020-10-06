class RenameEmployeeNumberToPersonnelNumber < ActiveRecord::Migration[5.2]
  def change
    rename_column :resb_employees_1c, :employee_number, :personnel_number
  end
end