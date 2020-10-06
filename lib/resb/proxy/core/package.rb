class Resb::Proxy::Core::Package < Resb::Proxy::Core::Base
  attr_reader :source
  node_reader :auth, :payload

  def initialize
    self.auth = Resb::Proxy::Core::Auth.new
    self.payload = Resb::Proxy::Core::Payload.new
  end

  def auth=(auth)
    raise ArgumentError.new('Expected Resb::Proxy::Core::Auth value') if auth.present? && !auth.is_a?(Resb::Proxy::Core::Auth)
    @auth = auth
  end

  def payload=(payload)
    raise ArgumentError.new('Expected Resb::Proxy::Core::Payload value') if payload.present? && !payload.is_a?(Resb::Proxy::Core::Payload)
    payload.package = self
    @payload = payload
  end

  def source=(source)
    @source = source.to_s
  end

  def handle
    self.payload.handle
  end

  def serialize
    xml_doc = Nokogiri::XML::Document.new
    xml_doc.encoding = 'UTF-8'
    elem = Nokogiri::XML::Element.new('package', xml_doc)
    xml_doc << elem
    super(elem, xml_doc)

    xml_doc
  end


  def self.from_xml_raw(xml_raw)
    begin
      xml = Nokogiri.parse(xml_raw).slop!
      return nil if xml.blank?
      xml = xml.package
    rescue
      return nil
    end
    p = Resb::Proxy::Core::Package.new
    p.unserialize(xml)
    p
  end
end