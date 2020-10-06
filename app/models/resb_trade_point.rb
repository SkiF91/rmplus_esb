class ResbTradePoint < ActiveRecord::Base
  belongs_to :department, class_name: 'UserDepartment', foreign_key: :department_id, optional: true

  validates_uniqueness_of :foreign_id

  before_save :detect_department

  private

  def detect_department
    if self.department_id.blank? && (self.new_record? || !self.department_id_changed?)
      self.department = UserDepartment.where('name like ?', self.name).first
    end
  end
end