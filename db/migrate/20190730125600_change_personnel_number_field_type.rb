class ChangePersonnelNumberFieldType < ActiveRecord::Migration[5.2]
  def self.up
    change_column :resb_employees_1c, :personnel_number, :string
  end

  def self.down
    change_column :resb_employees_1c, :personnel_number, :integer
  end
end