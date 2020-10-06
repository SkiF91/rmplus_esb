module Resb::LatePatches::Helpers
  module SdRequestsHelperPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        alias_method_chain :html_for_sd_request_field, :resb
        alias_method_chain :text_for_sd_request_field, :resb
      end
    end

    module InstanceMethods
      def html_for_sd_request_field_with_resb(req, field)
        case field
          when :resb_executor_company, :resb_initiator_company, :resb_executor_company_department, :resb_initiator_company_department
            text_for_sd_request_field(req, field)
          else
            html_for_sd_request_field_without_resb(req, field)
        end
      end

      def text_for_sd_request_field_with_resb(req, field)
        case field
          when :resb_executor_company
            if req.executor.present?
              req.executor.employees1c.map { |e| e.resb_organization.try(:name) }.compact.join(', ')
            else
              nil
            end
          when :resb_initiator_company
            if req.initiator.present?
              req.initiator.employees1c.map { |e| e.resb_organization.try(:name) }.compact.join(', ')
            else
              nil
            end
          when :resb_executor_company_department
            if req.executor.present?
              req.executor.employees1c.map { |e| e.resb_organization_department.try(:name) }.compact.join(', ')
            else
              nil
            end
          when :resb_initiator_company_department
            if req.initiator.present?
              req.initiator.employees1c.map { |e| e.resb_organization_department.try(:name) }.compact.join(', ')
            else
              nil
            end
          else
            text_for_sd_request_field_without_resb(req, field)
        end
      end
    end
  end
end
