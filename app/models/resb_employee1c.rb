class ResbEmployee1c < ActiveRecord::Base
  belongs_to :user, optional: true

  self.table_name = 'resb_employees_1c'

  scope :active, -> { where("(#{ResbEmployee1c.table_name}.deleted is null or #{ResbEmployee1c.table_name}.deleted = ?) and #{ResbEmployee1c.table_name}.fire_date is null ", false) }

  has_one :resb_organization, class_name: 'ResbOrganization', primary_key: 'resb_organization_guid', foreign_key: 'guid'

  has_one :resb_organization_department, class_name: 'ResbOrganizationDepartment', primary_key: 'resb_organization_department_guid', foreign_key: 'guid'

  has_one :resb_position, class_name: 'ResbPosition', primary_key: 'resb_position_guid', foreign_key: 'guid'

  has_many :kpi_period_user_resb_employees_1c, class_name: 'KpiPeriodUserResbEmployee1c', foreign_key: 'resb_employee_1c_id'

  has_many :kpi_period_users, class_name: 'KpiPeriodUser', through: :kpi_period_user_resb_employees_1c

  has_many :resb_timesheets,
           lambda { where("(#{ResbTimesheet.table_name}.deleted is null or #{ResbTimesheet.table_name}.deleted = 0)")},
           class_name: 'ResbTimesheet', primary_key: 'counting_guid', foreign_key: 'counting_guid'

  has_many :resb_vacation, class_name: 'ResbVacation', foreign_key: 'counting_guid', primary_key: 'counting_guid'

  after_save :set_users_by_dep_titles
  after_save :set_kpi_period_user

  def name(include_number=true)
    name_attrs = [self.resb_organization.try(:name) || '&times;', self.resb_organization_department.try(:name) || '&times;',
            self.resb_position.try(:name) || '&times;']
    name_attrs << (self.try(:personnel_number) || '&times;') if include_number
    name_attrs.join(' → ').html_safe
  end

  def is_fired?
    self.deleted?
  end

  private

  def set_users_by_dep_titles
    if self.saved_change_to_user_id?
      if self.user_id_before_last_save.present? && (u = User.where(id: self.user_id_before_last_save || self.user_id).first).present?
        u.resb_old_organizations = []
        u.fd_set_users_by_dep_titles(true)
      end

      self.user.fd_set_users_by_dep_titles(true)
      return
    end

    if self.user.present? && (self.saved_change_to_deleted? || self.saved_change_to_organization_inn? || self.saved_change_to_organization_kpp?)
      self.user.resb_old_organizations = ResbOrganization.where(deleted: false, INN: self.organization_inn_before_last_save, KPP: self.organization_kpp_before_last_save).to_a
      self.user.fd_set_users_by_dep_titles(true)
    end
  end

  def set_kpi_period_user
    return if self.user.blank?
    period_users = self.user.kpi_period_users.where('main_period = ? and (period_date = ? or period_date = ?)', true, Date.today.beginning_of_month, (Date.today - 1.month).beginning_of_month)
    if period_users.present?
      self.kpi_period_user_ids = (self.kpi_period_user_ids + period_users.ids).uniq

      #resb_organization_department = self.resb_organization_department
      #if resb_organization_department.present?
      #  period_users.each do |pu|
      #    pu.resb_organization_department_ids = (pu.resb_organization_department_ids + [resb_organization_department.id]).uniq
      #  end
      #end
    end
  end
end