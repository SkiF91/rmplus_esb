module Resb::LatePatches::Models
  module KpiUserCustomIndicatorPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        alias_method_chain :check_user_for_update?, :resb
      end
    end

    module InstanceMethods
      def check_user_for_update_with_resb?
        check_user_for_update_without_resb? && (User.current.admin? || !self.kpi_custom_indicator.esb_flag)
      end
    end
  end
end