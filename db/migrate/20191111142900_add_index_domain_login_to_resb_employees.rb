class AddIndexDomainLoginToResbEmployees < ActiveRecord::Migration[5.2]
  def change
    add_index :resb_employees, :domainLogin, unique: false
  end
end