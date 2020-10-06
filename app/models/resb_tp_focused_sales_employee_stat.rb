class ResbTpFocusedSalesEmployeeStat < ActiveRecord::Base
  belongs_to :tp_stat, class_name: 'ResbTpFocusedSalesStat', foreign_key: :stat_id, optional: true
  belongs_to :user, optional: true
end