class CreateResbPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :resb_positions do |t|
      t.string :guid
      t.boolean :deleted
      t.string :name
      t.timestamps
    end
  end
end