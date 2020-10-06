class Resb::Proxy::TradePointFocusedSalesStats < Resb::Proxy::Core::Body
  node_accessor :month
  node_accessor :trade_point_id, name: 'tradePointId'
  node_accessor :percent, name: 'plannedSalesPercentage'
  node_accessor :employee_stats, name: 'employee-stats/employee-stats-row', array: true, class: Resb::Proxy::TradePointFocusedSalesEmployeeStats

  def self.node_name
    'trade-point-focused-sales-stats'
  end

  def handle
    date = "#{self.month}-01".to_date
    trade_point = ResbTradePoint.where(foreign_id: self.trade_point_id).first
    tp = ResbTpFocusedSalesStat.where(trade_point_id: self.trade_point_id, period_date: date).first_or_initialize
    tp.percent = self.percent

    ests = (self.employee_stats || [])

    users = User.where("LOWER(login) IN (?)", ests.map { |u| u.login.downcase }.uniq + ['']).inject({}) { |h, u| h[u.login.to_s.downcase] = u; h }

    tp.employee_stats = ests.inject({}) { |h, est|
      h[est.login.to_s.downcase] = ResbTpFocusedSalesEmployeeStat.new(user: users[est.login.to_s.downcase], percent: est.percent)
      h
    }.values

    unless tp.save
      raise ActiveRecord::RecordNotSaved.new(tp.errors.full_messages.join("\n\t"))
    end

    tp.apply_indicators
  end
end