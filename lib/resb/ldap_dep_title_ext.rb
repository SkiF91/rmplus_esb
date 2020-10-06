module Redmine::FieldFormat
  module Ldap
    class DepTitlePartOrganization < DepTitlePart
      self.klass = ResbOrganization
      self.prefix = 'org'

      def self.options_scope
        ResbOrganization.active.sorted.select('name, id, updated_at')
      end

      def options_scope
        self.class.options_scope
      end

      def build_sql_condition
        "#{User.table_name}.id IN (#{ResbOrganization.active.with_employee.where("#{ResbOrganization.table_name}.id = ?", self.id).select('re.user_id').group('re.user_id').to_sql})"
      end
    end
  end
end