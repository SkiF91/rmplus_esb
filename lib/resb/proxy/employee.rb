class Resb::Proxy::Employee < Resb::Proxy::Core::Body
  node_accessor :id, :domainLogin, :firstName, :middleName, :lastName, :email, :gender, :dateOfBirth, :INN, :mobilePhone, :subdivisionId

  def handle
    employee = ResbEmployee.active.where(employeeId: self.id).first_or_initialize
    employee.attributes = {
          domainLogin: self.domainLogin,
          firstName: self.firstName,
          middleName: self.middleName,
          lastName: self.lastName,
          email: self.email,
          gender: self.gender,
          dateOfBirth: self.dateOfBirth,
          INN: self.INN,
          mobilePhone: self.mobilePhone,
          subdivisionId: self.subdivisionId,
          user_id: User.where(login: self.domainLogin).first.try(:id)
        }
      unless employee.save
        raise ActiveRecord::RecordNotSaved.new(employee.errors.full_messages.join("\n\t"))
      end
  end
end