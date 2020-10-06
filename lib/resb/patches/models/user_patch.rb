module Resb::Patches::Models
  module UserPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        has_many :employees1c, class_name: 'ResbEmployee1c', foreign_key: 'user_id'

        after_save :resb_assign_employee, prepend: true
        attr_accessor :resb_old_organizations
        has_many :resb_employees, inverse_of: :user
      end
    end

    module InstanceMethods

      def resb_organisations
        ResbOrganization.active.with_employee.where("re.user_id = ?", self.id)
      end

      def resb_assign_employee
        ResbEmployee.where(domainLogin: self.login).update_all(user_id: self.id)
        ResbEmployee1c.where(employee_id: self.ldap_foreign_id).update_all(user_id: self.id)
      end
    end
  end
end