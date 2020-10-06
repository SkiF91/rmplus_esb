class CreateStaffingPositionTables < ActiveRecord::Migration[5.2]
  def change
    create_table :resb_staffing_positions do |t|
      t.string :guid
      t.boolean :deleted
      t.string :name
      t.string :organization_department_guid
      t.string :position_guid
    end

    create_table :resb_staffing_position_reasons do |t|
      t.string :guid
      t.boolean :deleted
      t.string :name
    end

    add_index :resb_staffing_positions, :guid
    add_index :resb_staffing_position_reasons, :guid
    add_index :resb_staffing_positions, :organization_department_guid
    add_index :resb_staffing_positions, :position_guid
    add_index :resb_staffing_positions, [:guid, :organization_department_guid], name: 'index_guid_organization_department_guid'
    add_index :resb_staffing_positions, [:guid, :position_guid], name: 'index_guid_position_guid'
    add_index :resb_staffing_positions, [:guid, :organization_department_guid, :position_guid], name: 'index_guid_organization_department_guid_position_guid', unique: true
  end
end