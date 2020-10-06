class Resb::Proxy::Timesheet < Resb::Proxy::Core::Body
  node_accessor :id
  node_accessor :employee_id, name: 'employeeId'
  node_accessor :counting_guid, name: 'countingGUID'
  node_accessor :organization_department_guid, name: 'organizationDepartmentGUID'
  node_accessor :document_number, name: 'documentNumber'
  node_accessor :workdays, name: 'workdays/workday', array: true, class_name: Resb::Proxy::Workday
  node_reader :deleted

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    self.workdays.each do |workday|
      timesheet = ResbTimesheet.where(counting_guid: self.counting_guid, date: workday.date, organization_department_guid: self.organization_department_guid).first_or_initialize
      timesheet.attributes = {
        employee_id: self.employee_id,
        deleted: workday.hours == 0 ? true : !!self.deleted,
        hours: workday.hours.to_f,
        organization_department_guid: self.organization_department_guid,
        document_number: self.document_number,
        upload_date: DateTime.now
      }

      unless timesheet.save
        raise ActiveRecord::RecordNotSaved.new(employee.errors.full_messages.join("\n\t"))
      end
    end
  end
end