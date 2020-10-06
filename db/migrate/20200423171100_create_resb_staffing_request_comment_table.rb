class CreateResbStaffingRequestCommentTable < ActiveRecord::Migration[5.2]
  def change
    create_table :resb_staffing_request_comments do |t|
      t.string :guid
      t.boolean :deleted
      t.integer :request_id
      t.text :comment
    end

    add_index :resb_staffing_request_comments, :guid
    add_index :resb_staffing_request_comments, :request_id
    add_index :resb_staffing_request_comments, [:guid, :request_id], name: 'index_resb_staffing_req_comment_guid_req_id'
  end
end