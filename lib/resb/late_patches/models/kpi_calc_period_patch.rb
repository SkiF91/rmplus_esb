module Resb::LatePatches::Models
  module KpiCalcPeriodPatch
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods

      base.class_eval do
        class << self
          alias_method_chain :make_kpi_mark_fact_calc, :resb
        end
        alias_method_chain :activate, :resb
      end
    end

    module ClassMethods

      def make_kpi_mark_fact_calc_with_resb(period_user=nil)
        make_kpi_mark_fact_calc_without_resb(period_user)

        if period_user.present?
          ResbTpFocusedSalesStat.apply_stats(period_users: period_user)
        else
          ResbTpFocusedSalesStat.apply_stats(stats: ResbTpFocusedSalesStat.where(period_date: Date.today.beginning_of_month).to_a)
        end
      end
    end

    module InstanceMethods
      def activate_with_resb
        no_action = self.active?

        marks = activate_without_resb

        if !no_action && self.active? && self.persisted? && self.errors.blank?
          ResbTpFocusedSalesStat.apply_stats(period_users: self.kpi_period_users.to_a)
        end

        marks
      end
    end
  end
end