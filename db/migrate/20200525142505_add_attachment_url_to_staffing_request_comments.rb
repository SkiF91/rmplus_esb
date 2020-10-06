class AddAttachmentUrlToStaffingRequestComments < ActiveRecord::Migration[5.2]
  def change
    add_column :resb_staffing_request_comments, :attachment_url, :string
    add_column :resb_staffing_request_comments, :attachment_url_filename, :string
  end
end