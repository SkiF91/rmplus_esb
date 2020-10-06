class Resb::Proxy::Employee1c < Resb::Proxy::Core::Body
  node_accessor :organization_inn, name: 'organizationINN'
  node_accessor :organization_kpp, name: 'organizationKPP'
  node_accessor :hire_date, name: 'hireDate'
  node_accessor :fire_date, name: 'fireDate'
  node_accessor :counting_guid, name: 'countingGUID'
  node_accessor :employee_id, name: 'employeeId'
  node_accessor :resb_organization_guid, name: 'organizationGUID'
  node_accessor :resb_organization_department_guid, name: 'organizationDepartmentGUID'
  node_accessor :resb_position_guid, name: 'positionGUID'
  node_accessor :personnel_number, name: 'personnelNumber'

  node_reader :deleted

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    employee = ResbEmployee1c.where(counting_guid: self.counting_guid).first_or_initialize
    employee.attributes = {
        employee_id: self.employee_id,
        organization_inn: self.organization_inn,
        organization_kpp: self.organization_kpp,
        deleted: (!!self.deleted || (self.fire_date.present? && self.fire_date.to_date < Date.today)) ? true : !!self.deleted,
        hire_date: self.hire_date,
        fire_date: self.fire_date,
        resb_organization_guid: self.resb_organization_guid,
        resb_organization_department_guid: self.resb_organization_department_guid,
        resb_position_guid: self.resb_position_guid,
        personnel_number: self.personnel_number,
        user_id: User.where(ldap_foreign_id: self.employee_id).first.try(:id)
    }

    unless employee.save
      raise ActiveRecord::RecordNotSaved.new(employee.errors.full_messages.join("\n\t"))
    end
  end
end