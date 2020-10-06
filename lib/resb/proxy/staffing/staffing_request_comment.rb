class Resb::Proxy::Staffing::StaffingRequestComment < Resb::Proxy::Core::Body
  node_accessor :request_id, name: 'staffingRequestId'
  node_reader :deleted
  node_accessor :comment
  node_accessor :guid, name: 'GUID'
  node_accessor :attachment_url, name: 'attachmentUrl'

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    comment = ResbStaffingRequestComment.where(guid: self.guid).first_or_initialize

    comment.attributes = {
      request_id: self.request_id,
      deleted: !!self.deleted,
      comment: self.comment,
      attachment_url: self.attachment_url.to_s.gsub('\\', '/')
    }

    unless comment.save
      raise ActiveRecord::RecordNotSaved.new(comment.errors.full_messages.join("\n\t"))
    end
  end
end