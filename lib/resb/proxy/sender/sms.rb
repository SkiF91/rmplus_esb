class Resb::Proxy::Sender::Sms < Resb::Proxy::Core::Body
  node_accessor :to, :body, :type

  def handle
    true
  end
end