class CreateResb1cEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :resb_employees_1c do |t|
      t.string :counting_guid
      t.integer :employee_id
      t.string :organization_inn
      t.string :organization_kpp
      t.boolean :deleted
      t.date :hire_date
      t.date :fire_date
      t.string :resb_organization_guid
      t.string :resb_organization_department_guid
      t.string :resb_position_guid
      t.integer :employee_number
      t.integer :user_id
    end
  end
end