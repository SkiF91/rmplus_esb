class Resb::Proxy::Position < Resb::Proxy::Core::Body
  node_accessor :guid, name: 'GUID'
  node_accessor :name
  node_reader :deleted

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    position = ResbPosition.where(guid: self.guid).first_or_initialize
    position.attributes = {
      guid: self.guid,
      deleted: !!self.deleted,
      name: self.name,
    }

    unless position.save
      raise ActiveRecord::RecordNotSaved.new(position.errors.full_messages.join("\n\t"))
    end
  end
end