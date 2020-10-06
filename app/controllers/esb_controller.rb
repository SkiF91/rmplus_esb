class EsbController < ApplicationController
  before_action :require_login, only: [:request_staffing_comment_file]
  before_action :authorized_globaly?, only: [:package]
  accept_api_auth :package

  def package
    result = Resb::Esb.process(request.raw_post)
    render plain: result
  end

  def request_staffing_comment_file
    if Setting.plugin_rmplus_esb['attachment_vacation_path'].blank?
      render_404(message: l(:error_esb_staffing_files_path_not_configured))
      return
    end
    if params[:guid].blank?
      render_404(message: l(:error_esb_staffing_comment_not_found))
      return
    end

    comment = ResbStaffingRequestComment.where(guid: params[:guid]).first
    if comment.blank? || comment.attachment_url.blank?
      render_404(message: l(:error_esb_staffing_comment_not_found))
      return
    end
    attachment_url = comment.attachment_url.first == '/' ? comment.attachment_url[1, comment.attachment_url.length - 1] : comment.attachment_url
    settings_path = Setting.plugin_rmplus_esb['attachment_vacation_path'].last == '/' ? Setting.plugin_rmplus_esb['attachment_vacation_path'] : Setting.plugin_rmplus_esb['attachment_vacation_path'] + '/'
    file_path = settings_path + attachment_url

    if File.exist?(file_path)
      send_file file_path, file_name: comment.attachment_url_filename || "staffing_position_file_#{ DateTime.now.strftime('%Y-%m-%d %H%M%S') }", disposition: 'attachment'
    else
      render_404
    end
  end
end