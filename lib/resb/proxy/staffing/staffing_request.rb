class Resb::Proxy::Staffing::StaffingRequest < Resb::Proxy::Core::Body
  node_accessor :id
  node_reader :deleted
  node_accessor :description
  node_accessor :staffing_position_guid, name: 'staffingPositionGUID'
  node_accessor :staffing_position_reason_guid, name: 'staffingPositionReasonGUID'
  node_accessor :status
  node_accessor :deadline
  node_accessor :author_employee_id, name: 'authorEmployeeId'
  node_accessor :assigned_employee_id, name: 'assignedEmployeeId', nil: true


  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    req = SdRequest.find_by(id: self.id)
    staffing_position = ResbStaffingPosition.find_by(guid: self.staffing_position_guid)
    staffing_position_reason = ResbStaffingPositionReason.find_by(guid: self.staffing_position_reason_guid)

    if req.present?
      req.attributes = {
        description: self.description,
        resb_staffing_position_id: staffing_position.present? ? staffing_position.id : req.resb_staffing_position_id,
        resb_staffing_position_reason_id: staffing_position_reason.present? ? staffing_position_reason.id : req.resb_staffing_position_reason_id,
        due_date: self.deadline
      }

      unless req.save
        raise ActiveRecord::RecordNotSaved.new(req.errors.full_messages.join("\n\t"))
      end
    end
  end
end