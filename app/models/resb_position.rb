class ResbPosition < ActiveRecord::Base
  scope :sorted, -> { order(:name) }
  scope :active, -> { where("#{ResbPosition.table_name}.deleted IS NULL OR #{ResbPosition.table_name}.deleted = ?", false) }
  scope :with_employee, -> { joins("INNER JOIN #{ResbEmployee1c.table_name} re ON re.position_guid = #{ResbPosition.table_name}.guid ").where('re.deleted IS NULL OR re.deleted = ?', false) }

  def to_s
    self.name
  end

end