class ResbTimesheet < ActiveRecord::Base
  belongs_to :resb_employee_1c, class_name: 'ResbEmployee1c', foreign_key: 'counting_guid', primary_key: 'counting_guid'
  has_many :kpi_period_users, lambda { |args| where('period_date = ?', args.date.to_date.beginning_of_month) }, class_name: 'KpiPeriodUser', through: :resb_employee_1c

  #after_create :set_organization_department_to_period

  private
  def set_organization_department_to_period
    pu = self.kpi_period_users.joins(:resb_employees_1c).where("main_period = ? and #{ResbEmployee1c.table_name}.resb_organization_department_guid = ?", true, self.organization_department_guid).first
    return unless pu.present?
    resb_department = ResbOrganizationDepartment.find_by(guid: self.organization_department_guid)
    pu.resb_organization_department_ids = (pu.resb_organization_department_ids + [resb_department.id]).uniq if resb_department.present?
  end
end