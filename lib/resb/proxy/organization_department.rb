class Resb::Proxy::OrganizationDepartment < Resb::Proxy::Core::Body
  node_accessor :code, :name
  node_accessor :guid, name: 'GUID'
  node_accessor :organization_guid, name: 'organizationGUID'
  node_accessor :parent_guid, name: 'parentGUID'
  node_accessor :manager_guid, name: 'headGUID'
  node_accessor :acting_manager_guid, name: 'actingHeadGUID'

  node_reader :deleted

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    dep = ResbOrganizationDepartment.where(guid: self.guid).first_or_initialize
    dep.attributes = {
      code: self.code,
      guid: self.guid,
      deleted: !!self.deleted,
      name: self.name,
      organization_guid: self.organization_guid,
      parent_guid: self.parent_guid,
      manager_guid: self.manager_guid,
      acting_manager_guid: self.acting_manager_guid
    }

    unless dep.save
      raise ActiveRecord::RecordNotSaved.new(dep.errors.full_messages.join("\n\t"))
    end
  end
end