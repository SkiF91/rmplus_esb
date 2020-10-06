class AddResbDocumentUrlToSdRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_requests, :resb_document_url, :string
  end
end