class AddIndexesToResbOrganization < ActiveRecord::Migration[4.2]
  def change
    add_index :resb_organizations, [:INN, :KPP, :deleted], unique: false, name: 'index_resb_org_INN_KPP_del'
    add_index :resb_organizations, [:INN, :KPP], unique: false, name: 'index_resb_org_INN_KPP'
    add_index :resb_employees, [:organizationINN, :organizationKPP, :deleted], unique: false, name: 'index_resb_employees_INN_KPP_del'
    add_index :resb_employees, [:organizationINN, :organizationKPP], unique: false, name: 'index_resb_employees_INN_KPP'
  end
end