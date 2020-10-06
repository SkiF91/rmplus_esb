class Resb::Proxy::Organization < Resb::Proxy::Core::Body
  node_accessor :GUID, :personType, :name, :shortName, :fullName, :INN, :KPP
  node_reader :deleted

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    organisation = ResbOrganization.where(guid: self.GUID).first_or_initialize
    organisation.attributes = {
        personType: self.personType,
        name: self.name,
        shortName: self.shortName,
        fullName: self.fullName,
        INN: self.INN,
        KPP: self.KPP,
        deleted: !!self.deleted
    }

    unless organisation.save
      raise ActiveRecord::RecordNotSaved.new(organisation.errors.full_messages.join("\n\t"))
    end
  end
end