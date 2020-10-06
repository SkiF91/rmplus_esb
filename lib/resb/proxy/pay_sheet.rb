class Resb::Proxy::PaySheet < Resb::Proxy::Core::Body

  node_accessor :loginAD, :paySheetPeriod
  node_accessor :paySheetData

  def handle
    pay_sheet = ResbPaySheet.where(loginAD: self.loginAD, paySheetPeriod: self.paySheetPeriod).first_or_initialize
    pay_sheet.attributes = {
        loginAD: self.loginAD,
        paySheetPeriod: self.paySheetPeriod.to_date,
        user_id: User.where(login: self.loginAD).first.try(:id)
    }

    data = self.paySheetData.try(:data)

    if pay_sheet.user_id.present? && data.present?
      if self.paySheetData.algorithm == '7zip'
        decode_data = Base64.decode64(data).force_encoding('UTF-8')
        temp_file = Tempfile.new(['pay_sheet_' + Time.now.to_i.to_s, '.7z'])
        temp_file.write(decode_data)
        temp_file.close
        File.open(temp_file) do |file|
          SevenZipRuby::Reader.open(file, { password: Setting.plugin_rmplus_esb['payslip_password'] }) do |szr|
            szr.extract_all File.join(Rails.root, 'files', 'pay_sheets', pay_sheet.user_id.to_s, pay_sheet.paySheetPeriod.to_s )
          end
        end
      end
    end

    unless pay_sheet.save
      raise ActiveRecord::RecordNotSaved.new(employee.errors.full_messages.join("\n\t"))
    end
  end

end