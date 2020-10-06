class CreateResbVacations < ActiveRecord::Migration[5.2]
  def change
    create_table :resb_vacations do |t|
      t.string :guid
      t.boolean :deleted
      t.string :counting_guid
      t.string :substitute_counting_guid
      t.date :begin_date
      t.date :end_date
      t.timestamps
    end

    add_index :resb_vacations, :guid
    add_index :resb_vacations, :counting_guid
    add_index :resb_vacations, :substitute_counting_guid
    add_index :resb_vacations, [:guid, :counting_guid], name: 'index_resb_vacation_guid_counting_guid'
    add_index :resb_vacations, [:guid, :substitute_counting_guid], name: 'index_resb_vacation_guid_substitute_counting_guid'
    add_index :resb_vacations, [:counting_guid, :substitute_counting_guid], name: 'index_resb_vacation_counting_guid_substitute_counting_guid'
    add_index :resb_vacations, [:guid, :counting_guid, :substitute_counting_guid], name: 'index_resb_vacation_guid_counting_guid_substitute_counting_guid'

    add_column :user_vacations, :resb_vacation_guid, :string
    add_index :user_vacations, :resb_vacation_guid
    add_index :user_vacations, [:user_id, :resb_vacation_guid], name: 'index_user_vacations_user_id_resb_guid'
  end
end