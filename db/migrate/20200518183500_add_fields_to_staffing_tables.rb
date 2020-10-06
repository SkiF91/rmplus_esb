class AddFieldsToStaffingTables < ActiveRecord::Migration[5.2]
  def change
    add_column :resb_staffing_positions, :num_vacancies, :float
    add_index :resb_staffing_positions, :num_vacancies
  end
end