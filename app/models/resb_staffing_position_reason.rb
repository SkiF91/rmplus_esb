class ResbStaffingPositionReason < ActiveRecord::Base
  has_many :sd_requests, class_name: 'SdRequest', foreign_key: 'resb_staffing_position_reason_id'

  scope :sorted, -> { order(:name) }
  scope :active, -> { where("#{ResbStaffingPositionReason.table_name}.deleted IS NULL OR #{ResbStaffingPositionReason.table_name}.deleted = ?", false) }
end