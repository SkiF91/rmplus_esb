class ResbTpFocusedSalesStat < ActiveRecord::Base
  belongs_to :trade_point, class_name: 'ResbTradePoint', foreign_key: :trade_point_id, primary_key: :foreign_id, optional: true
  has_many :employee_stats, class_name: 'ResbTpFocusedSalesEmployeeStat', foreign_key: :stat_id, dependent: :delete_all


  def apply_indicators
    return if self.trade_point.blank? || self.trade_point.department.blank?

    self.class.apply_stats(stats: self)
  end

  def self.apply_stats(opts={})
    tp_ind_id = Setting.plugin_rmplus_esb['trade_point_custom_indicator_id'].to_i
    emp_ind_id = Setting.plugin_rmplus_esb['employee_custom_indicator_id'].to_i

    return if tp_ind_id == 0 && emp_ind_id == 0

    pu = opts[:period_users]
    stats = opts[:stats]

    if pu.present?
      pu = Array.wrap(pu)
    end

    if stats.present?
      stats = Array.wrap(stats)
    end

    return if pu.blank? && stats.blank?

    KpiPeriodUser.transaction do
      completed = {}
      scope = KpiUserCustomIndicator.joins({ kpi_period_user: :kpi_calc_period })
                                    .where("#{KpiPeriodUser.table_name}.locked = ?", false)
                                    .where("#{KpiCalcPeriod.table_name}.active = ?", true)
                                    .where("#{KpiUserCustomIndicator.table_name}.kpi_custom_indicator_id IN (?)", [tp_ind_id, emp_ind_id])
                                    .joins("LEFT JOIN #{ResbTradePoint.table_name} tp on tp.department_id = #{KpiPeriodUser.table_name}.user_department_id
                                            LEFT JOIN #{ResbTpFocusedSalesStat.table_name} st on st.trade_point_id = tp.foreign_id and st.period_date = #{KpiPeriodUser.table_name}.period_date
                                            LEFT JOIN #{ResbTpFocusedSalesEmployeeStat.table_name} emp on emp.stat_id = st.id and emp.user_id = #{KpiPeriodUser.table_name}.user_id
                                           ")
                                    .select("#{KpiUserCustomIndicator.table_name}.*,
                                             case when #{KpiUserCustomIndicator.table_name}.kpi_custom_indicator_id = #{tp_ind_id} then st.percent else emp.percent end as _percent
                                            ")

      if pu.present?
        scope = scope.where("#{KpiPeriodUser.table_name}.id IN (?)", pu.map(&:id))
      end

      if stats.present?
        scope = scope.where("st.id IN (?)", stats.map(&:id))
      end

      scope.readonly(false).each do |ci|
        next if completed[ci.id].present?
        completed[ci.id] = ci

        ci.update_attributes(value: ci.attributes['_percent'])
      end
    end
  end
end