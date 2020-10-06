class CreateResbOrganisationDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :resb_organization_departments do |t|
      t.integer :code
      t.string :guid
      t.boolean :deleted
      t.string :name
      t.string :organization_guid
      t.string :parent_guid
      t.timestamps
    end
  end
end