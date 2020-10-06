module Resb::LatePatches::Helpers
  module SdQueriesHelperPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        alias_method_chain :sd_options_for_reflection, :resb
      end
    end

    module InstanceMethods
      def sd_options_for_reflection_with_resb(field, ref=nil)
        if [:resb_executor_company, :resb_initiator_company].include?(field)
          sd_options_for_reflection_without_resb(field, ResbOrganization)
        elsif [:resb_executor_company_department, :resb_initiator_company_department].include?(field)
          sd_options_for_reflection_without_resb(field, ResbOrganizationDepartment.sorted_with_organization.preload(:organization))
        else
          sd_options_for_reflection_without_resb(field, ref)
        end
      end
    end
  end
end
