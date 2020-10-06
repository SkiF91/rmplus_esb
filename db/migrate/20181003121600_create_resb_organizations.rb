class CreateResbOrganizations < ActiveRecord::Migration[4.2]
  def change
    create_table :resb_organizations do |t|
      t.string :guid
      t.string :personType
      t.string :name
      t.string :shortName
      t.string :fullName
      t.string :INN
      t.string :KPP
      t.boolean :deleted
      t.timestamps
    end
  end
end