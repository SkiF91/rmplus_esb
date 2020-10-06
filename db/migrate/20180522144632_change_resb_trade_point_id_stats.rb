class ChangeResbTradePointIdStats < ActiveRecord::Migration[4.2]
  def up
    change_column :resb_tp_focused_sales_stats, :trade_point_id, :bigint
  end
end