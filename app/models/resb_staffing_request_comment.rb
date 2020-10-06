class ResbStaffingRequestComment < ActiveRecord::Base
  belongs_to :sd_request, class_name: 'SdRequest', foreign_key: 'request_id'

  validate :request_type_is_position

  before_save :set_comment_url
  after_save :create_sd_journal

  def request_type_is_position
    if self.sd_request && self.sd_request&.sd_request_type && !self.sd_request&.sd_request_type&.rmpi_show_staffing_fields
      self.errors.add(:base, l(:error_resb_request_type_not_available))
    end
  end

  private

  def set_comment_url
    return if self.attachment_url.blank?

    attachment_filename = self.attachment_url.to_s.split('/').last
    result_url = "\n#{l(:esb_label_request_position_comment_attachment_url)}: \"#{attachment_filename}\":#{Redmine::Utils.relative_url_root}/esb/request_staffing_comment_file/#{self.guid}".html_safe
    self.comment += result_url
    self.attachment_url_filename = attachment_filename
  end

  def create_sd_journal
    if self.sd_request.present?
      journal = SdJournal.new(user: User.current, journalized: self.sd_request, notes: self.comment)
      unless journal.save
        raise ActiveRecord::RecordNotSaved.new(journal.full_messages.join("\n\t"))
      end
    end
  end
end