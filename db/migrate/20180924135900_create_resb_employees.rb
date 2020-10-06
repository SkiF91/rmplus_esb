class CreateResbEmployees < ActiveRecord::Migration[4.2]
  def change
    create_table :resb_employees do |t|
      t.string :domainLogin
      t.string :firstName
      t.string :middleName
      t.string :lastName
      t.string :email
      t.string :gender
      t.integer :dateOfBirth
      t.string :INN
      t.string :mobilePhone
      t.integer :subdivisionId
      t.string :organizationINN
      t.string :organizationKPP
      t.date :hireDate
      t.date :fireDate
      t.string :countingGUID
      t.integer :employeeId
      t.boolean :deleted
      t.integer :user_id
      t.timestamps
    end

    add_index :resb_employees, [:user_id], unique: false
  end
end