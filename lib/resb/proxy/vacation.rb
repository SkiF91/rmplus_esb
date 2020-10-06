class Resb::Proxy::Vacation < Resb::Proxy::Core::Body
  node_accessor :guid, name: 'GUID'
  node_accessor :deleted
  node_accessor :counting_guid, name: 'countingGUID'
  node_accessor :substitute_counting_guid, name: 'substituteCountingGUID'
  node_accessor :begin_date, name: 'beginDate'
  node_accessor :end_date, name: 'endDate'

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def handle
    vacation = ResbVacation.where(guid: self.guid).first_or_initialize
    vacation.attributes = {
      deleted: !!self.deleted,
      counting_guid: self.counting_guid,
      substitute_counting_guid: self.substitute_counting_guid,
      begin_date: self.begin_date,
      end_date: self.end_date
    }

    unless vacation.save
      raise ActiveRecord::RecordNotSaved.new(employee.full_messages.join("\n\t"))
    end
  end
end