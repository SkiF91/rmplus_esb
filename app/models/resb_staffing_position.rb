class ResbStaffingPosition < ActiveRecord::Base
  has_one :organization_department, class_name: 'ResbOrganizationDepartment', foreign_key: :guid, primary_key: :organization_department_guid
  has_many :sd_requests, class_name: 'SdRequest', foreign_key: 'resb_staffing_position_id'

  scope :sorted, -> { order(:name) }
  scope :active, -> { where("#{ResbStaffingPosition.table_name}.deleted IS NULL OR #{ResbStaffingPosition.table_name}.deleted = ?", false) }

  def to_s
    self.name
  end

  def name
    if self.association(:organization_department).loaded? && self.organization_department.present?
      "#{self.organization_department.name} - #{super}"
    else
      super
    end
  end
end