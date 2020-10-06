module Resb::LatePatches::Models
  module SdQueryPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        self.fields[:resb_executor_company] = :list
        self.fields[:resb_initiator_company] = :list
        self.fields[:resb_executor_company_department] = :list
        self.fields[:resb_initiator_company_department] = :list
        #self.cant_be_grouped << [:resb_executor_company, :resb_initiator_company, :resb_executor_company_department, :resb_initiator_company_department]

        self.fields_options.clear
        self.fields_options.merge!(self.fields_options_loader)

        alias_method_chain :sd_requests, :resb
        alias_method_chain :sort_statement_for_rule, :resb
        alias_method_chain :left_join_statement_for_field, :resb
        alias_method_chain :count_statement_for_group_field, :resb
        alias_method_chain :expression_statement, :resb
        alias_method_chain :group_value, :resb
      end
    end

    module InstanceMethods
      def sd_requests_with_resb
        scope = sd_requests_without_resb

        ex_company_filter = nil
        in_company_filter = nil
        self.filters.each do |f|
          if f[0] == :resb_executor_company
            ex_company_filter = Array.wrap(f[2]) - ['', nil]
          elsif f[0] == :resb_initiator_company
            in_company_filter = Array.wrap(f[2]) - ['', nil]
          end
        end

        if (self.selected_fields || []).include?(:resb_executor_company)
          scope.add_after_exec do |records|
            preloader = ActiveRecord::Associations::Preloader.new
            loaders = preloader.preload(records, :executor)
            recs = loaders.flat_map(&:preloaded_records).uniq
            loaders = preloader.preload(recs, :employees1c, ResbEmployee1c.active)
            recs = loaders.flat_map(&:preloaded_records).uniq
            preloader.preload(recs, :resb_organization)
          end
        end

        if (self.selected_fields || []).include?(:resb_executor_company_department)
          scope.add_after_exec do |records|
            preloader = ActiveRecord::Associations::Preloader.new
            loaders = preloader.preload(records, :executor)
            recs = loaders.flat_map(&:preloaded_records).uniq

            if ex_company_filter.present?
              loaders = preloader.preload(recs, :employees1c, ResbEmployee1c.joins(:resb_organization).active.where(resb_organizations: { id: ex_company_filter }))
            else
              loaders = preloader.preload(recs, :employees1c, ResbEmployee1c.active)
            end
            recs = loaders.flat_map(&:preloaded_records).uniq
            preloader.preload(recs, resb_organization_department: :organization)
          end
        end

        if (self.selected_fields || []).include?(:resb_initiator_company)
          scope.add_after_exec do |records|
            preloader = ActiveRecord::Associations::Preloader.new
            loaders = preloader.preload(records, :initiator)
            recs = loaders.flat_map(&:preloaded_records).uniq
            loaders = preloader.preload(recs, :employees1c, ResbEmployee1c.active)
            recs = loaders.flat_map(&:preloaded_records).uniq
            preloader.preload(recs, :resb_organization)
          end
        end

        if (self.selected_fields || []).include?(:resb_initiator_company_department)
          scope.add_after_exec do |records|
            preloader = ActiveRecord::Associations::Preloader.new
            loaders = preloader.preload(records, :initiator)
            recs = loaders.flat_map(&:preloaded_records).uniq

            if in_company_filter.present?
              loaders = preloader.preload(recs, :employees1c, ResbEmployee1c.joins(:resb_organization).active.where(resb_organizations: { id: in_company_filter }))
            else
              loaders = preloader.preload(recs, :employees1c, ResbEmployee1c.active)
            end

            recs = loaders.flat_map(&:preloaded_records).uniq
            preloader.preload(recs, resb_organization_department: :organization)
          end
        end

        scope
      end

      def sort_statement_for_rule_with_resb(sort_rule)
        if SdQuery.fields[sort_rule[:field]] != :list
          return sort_statement_for_rule_without_resb(sort_rule)
        end

        case sort_rule[:field]
          when :resb_executor_company
            "resb_company_for_ex.name #{sort_rule[:sort]}"
          when :resb_initiator_company
            "resb_company_for_in.name #{sort_rule[:sort]}"
          when :resb_executor_company_department
            "resb_company_dep_for_ex.org_name #{sort_rule[:sort]}, resb_company_dep_for_ex.name #{sort_rule[:sort]}"
          when :resb_initiator_company_department
            "resb_company_dep_for_in.org_name #{sort_rule[:sort]}, resb_company_dep_for_in.name #{sort_rule[:sort]}"
        else
          sort_statement_for_rule_without_resb(sort_rule)
        end
      end

      def left_join_statement_for_field_with_resb(field)
        if field == :resb_executor_company
          "LEFT JOIN (
              SELECT e1.user_id, o.id, o.name
              FROM (#{ResbEmployee1c.active.select("#{ResbEmployee1c.table_name}.user_id, MAX(#{ResbEmployee1c.table_name}.id) as mid").group("#{ResbEmployee1c.table_name}.user_id").to_sql}) e1m
                   INNER JOIN #{ResbEmployee1c.table_name} e1 ON e1.id = e1m.mid
                   INNER JOIN #{ResbOrganization.table_name} o on o.guid = e1.resb_organization_guid
          ) resb_company_for_ex ON resb_company_for_ex.user_id = #{SdRequest.table_name}.executor_id"
        elsif field == :resb_initiator_company
          "LEFT JOIN (
              SELECT e1.user_id, o.id, o.name
              FROM (#{ResbEmployee1c.active.select("#{ResbEmployee1c.table_name}.user_id, MAX(#{ResbEmployee1c.table_name}.id) as mid").group("#{ResbEmployee1c.table_name}.user_id").to_sql}) e1m
                   INNER JOIN #{ResbEmployee1c.table_name} e1 ON e1.id = e1m.mid
                   INNER JOIN #{ResbOrganization.table_name} o on o.guid = e1.resb_organization_guid
          ) resb_company_for_in ON resb_company_for_in.user_id = #{SdRequest.table_name}.initiator_id"
        elsif field == :resb_executor_company_department
          "LEFT JOIN (
              SELECT e1.user_id, d.id, o.name as org_name, d.name
              FROM (#{ResbEmployee1c.active.select("#{ResbEmployee1c.table_name}.user_id, MAX(#{ResbEmployee1c.table_name}.id) as mid").group("#{ResbEmployee1c.table_name}.user_id").to_sql}) e1m
                   INNER JOIN #{ResbEmployee1c.table_name} e1 ON e1.id = e1m.mid
                   INNER JOIN #{ResbOrganizationDepartment.table_name} d on d.guid = e1.resb_organization_department_guid
                   INNER JOIN #{ResbOrganization.table_name} o on o.guid = d.organization_guid
          ) resb_company_dep_for_ex ON resb_company_dep_for_ex.user_id = #{SdRequest.table_name}.executor_id"
        elsif field == :resb_initiator_company_department
          "LEFT JOIN (
              SELECT e1.user_id, d.id, o.name as org_name, d.name
              FROM (#{ResbEmployee1c.active.select("#{ResbEmployee1c.table_name}.user_id, MAX(#{ResbEmployee1c.table_name}.id) as mid").group("#{ResbEmployee1c.table_name}.user_id").to_sql}) e1m
                   INNER JOIN #{ResbEmployee1c.table_name} e1 ON e1.id = e1m.mid
                   INNER JOIN #{ResbOrganizationDepartment.table_name} d on d.guid = e1.resb_organization_department_guid
                   INNER JOIN #{ResbOrganization.table_name} o on o.guid = d.organization_guid
          ) resb_company_dep_for_in ON resb_company_dep_for_in.user_id = #{SdRequest.table_name}.initiator_id"
        else
          left_join_statement_for_field_without_resb(field)
        end
      end

      def count_statement_for_group_field_with_resb
        if SdQuery.fields[self.group_field] != :list
          return count_statement_for_group_field_without_resb
        end

        case self.group_field
          when :resb_executor_company
            'resb_company_for_ex.id'
          when :resb_initiator_company
            'resb_company_for_in.id'
          when :resb_executor_company_department
            'resb_company_dep_for_ex.id'
          when :resb_initiator_company_department
            'resb_company_dep_for_in.id'
          else
            count_statement_for_group_field_without_resb
        end
      end

      def group_value_with_resb(req)
        return group_value_without_resb(req) unless self.grouped?

        case self.group_field
          when :resb_executor_company
            req.executor.try(:employees1c).try(:last).try(:resb_organization).try(:id)
          when :resb_initiator_company
            req.initiator.try(:employees1c).try(:last).try(:resb_organization).try(:id)
          when :resb_executor_company_department
            req.executor.try(:employees1c).try(:last).try(:resb_organization_department).try(:id)
          when :resb_initiator_company_department
            req.initiator.try(:employees1c).try(:last).try(:resb_organization_department).try(:id)
          else
            group_value_without_resb(req)
        end
      end

      def expression_statement_with_resb(field, fld, expr, values, has_empty)
        case field
          when :resb_executor_company, :resb_initiator_company
            expr = '-' if values.nil?
            values = Array.wrap(values)
            return '1=0' if values.blank? && %w(= !).include?(expr)

            sd_field = field == :resb_executor_company ? "#{SdRequest.table_name}.executor_id" : "#{SdRequest.table_name}.initiator_id"

            case expr
              when '+', '-'
                e = "EXISTS(#{ResbEmployee1c.joins(:resb_organization).active.where("#{ResbEmployee1c.table_name}.user_id = #{sd_field}").select('1').to_sql})"
                expr == '-' ? "NOT #{e}" : e
              when '=', '!'
                e = "EXISTS(#{ResbEmployee1c.joins(:resb_organization).active.where("#{ResbEmployee1c.table_name}.user_id = #{sd_field} AND #{ResbOrganization.table_name}.id IN (?)", values).select('1').to_sql})"
                expr == '!' ? "NOT #{e}" : e
              else
                '1=0'
            end
          when :resb_executor_company_department, :resb_initiator_company_department
            expr = '-' if values.nil?
            values = Array.wrap(values)
            return '1=0' if values.blank? && %w(= !).include?(expr)

            sd_field = field == :resb_executor_company_department ? "#{SdRequest.table_name}.executor_id" : "#{SdRequest.table_name}.initiator_id"
            case expr
              when '+', '-'
                e = "EXISTS(#{ResbEmployee1c.joins(:resb_organization_department).active.where("#{ResbEmployee1c.table_name}.user_id = #{sd_field}").select('1').to_sql})"
                expr == '-' ? "NOT #{e}" : e
              when '=', '!'
                e = "EXISTS(#{ResbEmployee1c.joins(:resb_organization_department).active.where("#{ResbEmployee1c.table_name}.user_id = #{sd_field} AND #{ResbOrganizationDepartment.table_name}.id IN (?)", values).select('1').to_sql})"
                expr == '!' ? "NOT #{e}" : e
              else
                '1=0'
            end
          else
            expression_statement_without_resb(field, fld, expr, values, has_empty)
        end
      end
    end
  end
end