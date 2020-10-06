class Resb::Proxy::Staffing::StaffingPosition < Resb::Proxy::Core::Body
  node_accessor :guid, name: 'GUID'
  node_reader :deleted
  node_accessor :name
  node_accessor :organization_department_guid, name: 'organizationDepartmentGUID'
  node_accessor :position_guid, name: 'positionGUID'
  node_accessor :num_vacancies, name: 'numVacancies'

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    position = ResbStaffingPosition.where(guid: self.guid).first_or_initialize
    organization_department = ResbOrganizationDepartment.find_by(guid: self.organization_department_guid)

    position.attributes = {
      guid: self.guid,
      deleted: !!self.deleted,
      name: self.name,
      organization_department_guid: self.organization_department_guid,
      position_guid: self.position_guid,
      num_vacancies: self.num_vacancies,
      organization_guid: organization_department&.organization_guid
    }

    unless position.save
      raise ActiveRecord::RecordNotSaved.new(position.errors.full_messages.join("\n\t"))
    end
  end
end