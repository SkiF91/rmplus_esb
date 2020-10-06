class AddIndexesToResbEmployees1c < ActiveRecord::Migration[5.2]
  def change
    add_index :resb_employees_1c, [:organization_inn, :organization_kpp, :deleted], unique: false, name: 'index_resb_employees_1c_INN_KPP_del'
    add_index :resb_employees_1c, [:organization_inn, :organization_kpp], unique: false, name: 'index_resb_employees_1c_INN_KPP'
    add_index :resb_employees_1c, [:user_id], unique: false
  end
end