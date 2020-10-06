class ChangeResbTradePointForeignIdType < ActiveRecord::Migration[4.2]
  def up
    change_column :resb_trade_points, :foreign_id, :bigint
  end
end