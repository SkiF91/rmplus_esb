class ResbOrganization < ActiveRecord::Base
  scope :sorted, -> { order(:name) }
  scope :active, -> { where("#{ResbOrganization.table_name}.deleted is null or #{ResbOrganization.table_name}.deleted = ?", false) }
  scope :with_employee, -> { joins("INNER JOIN #{ResbEmployee1c.table_name} re ON re.organization_inn = #{ResbOrganization.table_name}.INN and re.organization_kpp = #{ResbOrganization.table_name}.KPP").where('re.deleted IS NULL OR re.deleted = ?', false) }

  after_save :set_users_by_dep_titles

  has_many :kpi_period_user, class_name: 'KpiPeriodUser', foreign_key: 'guid'

  def to_s
    self.name
  end

  def self.fields_for_order_statement(table=nil)
    table ||= table_name
    ["#{table}.name", "#{table}.id"]
  end

  private

  def set_users_by_dep_titles
    if self.saved_change_to_INN? || self.saved_change_to_KPP?
      if self.INN_before_last_save.present? && self.KPP_before_last_save.present?
        users_before = ResbEmployee1c.active.where(organization_inn: self.INN_before_last_save, organization_kpp: self.KPP_before_last_save).pluck(:user_id)
      else
        users_before = []
      end
      if self.INN.present? && self.KPP.present?
        users_after = ResbEmployee1c.active.where(organization_inn: self.INN, organization_kpp: self.KPP).pluck(:user_id)
      else
        users_after = []
      end

      User.fd_set_users_by_dep_titles("org#{self.id.to_i}", users_before, users_after)
    end
  end

  def destroy(*args)
    users_before = []
    unless self.deleted?
      users_before = ResbOrganization.with_employee.where("#{ResbOrganization.table_name}.id = ?", self.id).distinct.pluck('re.user_id')
    end

    res = super
    User.fd_set_users_by_dep_titles("s#{self.id.to_i}", users_before, [])
    res
  end
end