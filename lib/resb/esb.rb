class Resb::Esb
  class EsbError < StandardError
  end

  class EsbUnknownClass < EsbError
  end

  SUCCESS_CODE = 0
  ERROR_CODE = 1

  class << self
    def class_mapper
      {
        'sms' => Resb::Proxy::Sender::Sms,
        'rocket' => Resb::Proxy::Sender::Rocket,
        'staffing_position' => Resb::Proxy::Staffing::StaffingPosition,
        'staffing_position_reason' => Resb::Proxy::Staffing::StaffingPositionReason,
        'staffing_request' => Resb::Proxy::Staffing::StaffingRequest,
        'staffing_request_comment' => Resb::Proxy::Staffing::StaffingRequestComment,
        'staffing_request_link' => Resb::Proxy::Staffing::StaffingRequestLink
      }
    end

    def logger
      return @logger if @logger

      path = File.join(Rails.root, 'log', 'esb')

      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end

      @logger = ::Logger.new(File.join(path, 'esb.log'), 'daily')
    end

    def process(xml_raw)
      begin
        xml_raw.to_s.force_encoding('UTF-8')
        self.logger.info "Received XML: \n============================\n#{xml_raw}\n============================\n"

        package = Resb::Proxy::Core::Package.from_xml_raw(xml_raw)
        if package.nil?
          raise StandardError.new('XML is not valid')
        end
        package.handle

        self.logger.info "SUCCESS\n============================\n"
        r = self.generate_result(SUCCESS_CODE)
      rescue Resb::Esb::EsbUnknownClass => ex
        self.logger.error "ERROR: #{ex.message} (#{ex.class})\n\t#{ex.backtrace.join("\n\t")}\n============================\n"
        r = self.generate_result(SUCCESS_CODE)
      rescue Exception => ex
        self.logger.error "ERROR: #{ex.message} (#{ex.class})\n\t#{ex.backtrace.join("\n\t")}\n============================\n"
        r = self.generate_result(ERROR_CODE, ex.message)
      end

      r = r.serialize.to_xml
      self.logger.info "RESPONSE: \n #{r}\n============================\n"
      r
    end

    def generate_result(code, message=nil)
      ResbLog.create(code: code, message: message)
      result = Resb::Proxy::Core::Result.new(code)
      result.response.message = message
      result
    end

    # @param [Resb::Proxy::Core::Body] body
    def send_to_esb(body)
      package = Resb::Proxy::Core::Package.new
      package.auth.app_id = Setting.plugin_rmplus_esb['esb_app_id']
      package.auth.token = Setting.plugin_rmplus_esb['esb_token']

      body.payload = package.payload
      package.payload.items << body

      initialize_query(package)
    end

    private

    def initialize_query(package)
      begin
        url = Setting.plugin_rmplus_esb['esb_url']
        raise StandardError.new('ESB not configured') if url.blank?

        xml_raw = package.serialize.to_xml
        self.logger.info "Sending XML: #{url} \n============================\n#{xml_raw}\n============================\n"

        2.times do |try|
          begin

            uri = URI(url)

            self.logger.info "URL: #{uri.hostname}:#{uri.port}\n============================\n"

            req = Net::HTTP::Post.new(uri)
            req.body = xml_raw
            req.content_type = 'application/xml'

            res = Net::HTTP.start(uri.hostname, uri.port) do |http|
              http.read_timeout = 10
              http.request(req)
            end

            raise StandardError.new("Response is not success #{res.inspect}\n RESPONSE: \n #{res.body}\n============================\n") unless res.is_a?(Net::HTTPSuccess)
            raise StandardError.new("Response body is blank") if res.body.blank?

            self.logger.info "RESPONSE: \n #{res.body}\n============================\n"

            res = Hash.from_trusted_xml(res.body)
            raise StandardError.new('Response body is not valid xml') if res.nil? || !res.is_a?(Hash)

            if res.is_a?(Hash) && res['result'].present? && res['result'].is_a?(Hash) && res['result']['code'].to_i == 0
              self.logger.info "SUCCESS\n============================\n"
              return true
            end
          rescue => ex
            self.logger.error "ERROR - TRY #{try}: #{ex.message} (#{ex.class})\n\t#{ex.backtrace.join("\n\t")}\n============================\n"
          end
        end
      rescue => ex
        self.logger.error "ERROR: #{ex.message} (#{ex.class})\n\t#{ex.backtrace.join("\n\t")}\n============================\n"
      end

      false
    end
  end
end