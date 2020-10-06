class AddEsbFlagToKpiCustomIndicators < ActiveRecord::Migration[4.2]
  def change
    add_column :kpi_custom_indicators, :esb_flag, :boolean, null: true
    add_column :kpi_period_custom_indicators, :esb_flag, :boolean, null: true
  end
end