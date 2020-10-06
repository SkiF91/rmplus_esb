class Resb::Proxy::Core::Auth < Resb::Proxy::Core::Base
  attr_reader :app_id, name: :appId
  attr_reader :token

  def app_id=(app_id)
    @app_id = app_id.to_s
  end

  def token=(token)
    @token = token.to_s
  end
end