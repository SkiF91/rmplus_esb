class CreateResbStats < ActiveRecord::Migration[4.2]
  def change
    create_table :resb_tp_focused_sales_stats do |t|
      t.integer :trade_point_id
      t.date :period_date
      t.float :percent
      t.timestamps
    end

    add_index :resb_tp_focused_sales_stats, [:period_date], name: 'index_resb_tp_fss_p', unique: false
    add_index :resb_tp_focused_sales_stats, [:trade_point_id], name: 'index_resb_tp_fss_t', unique: false
    add_index :resb_tp_focused_sales_stats, [:trade_point_id, :period_date], name: 'index_resb_tp_fss_tp', unique: true

    create_table :resb_tp_focused_sales_employee_stats do |t|
      t.integer :stat_id
      t.integer :user_id
      t.float :percent
    end

    add_index :resb_tp_focused_sales_employee_stats, [:stat_id], name: 'resb_tp_fses_stat_id', unique: false
    add_index :resb_tp_focused_sales_employee_stats, [:user_id], name: 'resb_tp_fses_user_id', unique: false
    add_index :resb_tp_focused_sales_employee_stats, [:stat_id, :user_id], name: 'resb_tp_fses_su', unique: true
  end
end