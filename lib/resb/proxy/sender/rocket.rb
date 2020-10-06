class Resb::Proxy::Sender::Rocket < Resb::Proxy::Core::Body
  node_accessor :to, :body

  def handle
    true
  end
end