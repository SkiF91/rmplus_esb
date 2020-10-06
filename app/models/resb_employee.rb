class ResbEmployee < ActiveRecord::Base
  belongs_to :user, inverse_of: :resb_employees, optional: true
  scope :active, -> { where("#{ResbEmployee.table_name}.deleted is null or #{ResbEmployee.table_name}.deleted = ?", false) }
end