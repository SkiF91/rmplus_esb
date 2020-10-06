class Resb::Proxy::Core::Payload < Resb::Proxy::Core::Base
  def package
    @package
  end

  def package=(value)
    @package = value
  end

  def items
    @items ||= []
  end

  def items=(value)
    @items = value
  end

  def handle
    self.items.each { |it| it.handle }
  end

  def unserialize(xml)
    super

    self.items = xml.elements.map do |xml_obj|
      obj = self.class.unserialize_node(xml_obj)
      obj.payload = self
      obj
    end
  end

  def serialize(elem, xml_doc)
    super

    elem << Nokogiri::XML::NodeSet.new(xml_doc) do |set|
      self.items.each do |it|
        _v = self.class.serialize_node(it.class.node_name, it, xml_doc, {})
        set << _v if _v.present?
      end
    end
  end
end