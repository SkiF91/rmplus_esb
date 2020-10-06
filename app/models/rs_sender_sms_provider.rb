class RsSenderSmsProvider < RsSender
  after_initialize :init_defaults

  def self.form_fields
    super + [:to]
  end

  def sender_identifier
    'SMS'
  end

  def send_message_by_msg(msg)
    res = true
    msg.recipients.each do |r|
      msg_to = r.msg_to
      next if msg_to.blank?

      if msg_to.is_a?(User)
        next unless msg_to.active?
        self.msg_to(msg_to).each do |phone|
          res &= send_single_message(msg.id, phone, msg.body)
        end
      else
        res &= send_single_message(msg.id, msg_to, msg.body)
      end
    end

    res
  end

  def msg_to(user=nil)
    if Redmine::Plugin.installed?(:ldap_users_sync)
      return [user] unless user.is_a?(User)
      return [] if user.blank? || user.user_phones.blank?
      cell_phone = user.user_phones.detect { |p| p.phone_type == 'cell' }
      return [] if cell_phone.blank? || cell_phone.phone.blank?
      cell_phone = cell_phone.phone.gsub(/[^\d]+/, '')
      cell_phone.size == 11 ? [cell_phone] : []
    else
      []
    end
  end

  def valid_settings?
    true
  end

  private

  def send_single_message(id, msg_to, body)
    payload_body = Resb::Proxy::Sender::Sms.new
    payload_body.message_id = "#{SecureRandom.uuid}-#{id}"
    payload_body.to = msg_to
    payload_body.body = body
    payload_body.type = self.settings[:type_sms]

    Resb::Esb.send_to_esb(payload_body)
  end

  def init_defaults
    opts = { type_sms: '' }
    if self.new_record? && self.settings.blank?
      self.settings = opts
    else
      self.settings = opts.with_indifferent_access.merge(self.settings.with_indifferent_access.slice(*opts.keys))
    end
  end
end