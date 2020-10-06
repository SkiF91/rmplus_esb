class ResbVacation < ActiveRecord::Base
  belongs_to :resb_employee, class_name: 'ResbEmployee1c', foreign_key: 'counting_guid', primary_key: 'counting_guid'

  validates_presence_of :counting_guid, :begin_date, :end_date

  after_save :create_vacation

  private

  def create_vacation
    employee = self.resb_employee
    substitute_employee = nil
    substitute_employee = ResbEmployee1c.where(counting_guid: self.substitute_counting_guid).first if self.substitute_counting_guid.present?

    return if employee.nil?
    return if employee.user_id.nil?

    uv = UserVacation.where(user_id: employee.user_id, resb_vacation_guid: self.guid).first_or_initialize

    if self.deleted
      uv.destroy unless uv.new_record?
      return
    end

    days = (self.end_date - self.begin_date).to_i
    ActiveRecord::Base.transaction do
      uv.start_date = self.begin_date
      uv.end_date = self.end_date
      uv.days = days
      uv.deputy_id = substitute_employee&.user_id

      if uv.new_record? || uv.changed?
        UserVacation.where('start_date = ? AND end_date = ? and user_id = ? and id <> ?', self.begin_date, self.end_date, employee.user_id, uv.id.to_i).destroy_all
        raise ActiveRecord::Rollback unless uv.save
      end
    end
  end
end