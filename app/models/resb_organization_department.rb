class ResbOrganizationDepartment < ActiveRecord::Base
  has_one :organization, class_name: 'ResbOrganization', foreign_key: :guid, primary_key: :organization_guid

  scope :with_organization, -> { joins(:organization) }
  scope :sorted_with_organization, -> { joins(:organization).order("#{ResbOrganization.table_name}.name, #{ResbOrganizationDepartment.table_name}.name") }
  scope :sorted, -> { order(:name) }
  scope :active, -> { where("#{ResbOrganizationDepartment.table_name}.deleted IS NULL OR #{ResbOrganizationDepartment.table_name}.deleted = ?", false) }
  scope :with_employee, -> { joins("INNER JOIN #{ResbEmployee1c.table_name} re ON re.resb_organization_department_guid = #{ResbOrganizationDepartment.table_name}.guid ").where('re.deleted IS NULL OR re.deleted = ?', false) }

  def to_s
    self.name
  end

  def name
    if self.association(:organization).loaded? && self.organization.present?
      "#{self.organization.name} - #{super}"
    else
      super
    end
  end
end