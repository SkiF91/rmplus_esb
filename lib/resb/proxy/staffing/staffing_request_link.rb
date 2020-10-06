class Resb::Proxy::Staffing::StaffingRequestLink < Resb::Proxy::Core::Body
  node_accessor :req_id, name: 'staffingRequestId'
  node_accessor :document_url, name: 'documentUrl'

  def handle
    req = SdRequest.find_by(id: self.req_id)

    if req.present?
      req.attributes = {
        resb_document_url: self.document_url
      }

      unless req.save
        raise ActiveRecord::RecordNotSaved.new(req.errors.full_messages.join("\n\t"))
      end
    end
  end
end