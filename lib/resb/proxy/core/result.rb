class Resb::Proxy::Core::Result < Resb::Proxy::Core::Base
  attr_accessor :code
  node_reader :response

  def response=(value)
    raise ArgumentError.new('Expected Resb::Proxy::Core::Response value') if value.present? && !value.is_a?(Resb::Proxy::Core::Response)
    @response = value
  end

  def initialize(code=nil, response=nil)
    self.code = code || Resb::Esb::SUCCESS_CODE
    self.response = response || Resb::Proxy::Core::Response.new(self.code)
  end

  def serialize
    xml_doc = Nokogiri::XML::Document.new
    xml_doc.encoding = 'UTF-8'
    elem = Nokogiri::XML::Element.new('result', xml_doc)
    xml_doc << elem
    super(elem, xml_doc)

    xml_doc
  end
end