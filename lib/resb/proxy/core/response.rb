class Resb::Proxy::Core::Response < Resb::Proxy::Core::Base
  attr_accessor :code
  attr_accessor :object_id, name: 'objectId'
  node_accessor :message

  def initialize(code=nil)
    self.code = code || Resb::Esb::SUCCESS_CODE
  end
end