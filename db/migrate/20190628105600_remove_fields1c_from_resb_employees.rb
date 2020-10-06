class RemoveFields1cFromResbEmployees < ActiveRecord::Migration[5.2]
  def up
    emps1c = ''
    employees = ResbEmployee.where('countingGUID is not null')
    employees.each do |emp|
      emps1c += "(#{emp.employeeId.present? ? "'#{emp.employeeId}'" : 'NULL'}, "
      emps1c += "#{emp.countingGUID.present? ? "'#{emp.countingGUID}'" : 'NULL'}, "
      emps1c += "#{emp.organizationINN.present? ? "'#{emp.organizationINN}'" : 'NULL'}, "
      emps1c += "#{emp.organizationKPP.present? ? "'#{emp.organizationKPP}'" : 'NULL'}, "
      emps1c += "#{emp.hireDate.present? ? "'#{emp.hireDate}'" : 'NULL'}, "
      emps1c += "#{emp.fireDate.present? ? "'#{emp.fireDate}'" : 'NULL'}, "
      emps1c += "#{emp.deleted.present? ? "#{emp.deleted}" : 'NULL'}, "
      emps1c += "#{emp.user_id.present? ? "'#{emp.user_id}'" : 'NULL'})#{emp.id == employees.last.id ? ';' : ', '}"
    end

    if emps1c.length > 0
      ActiveRecord::Base.connection.execute("INSERT INTO #{ResbEmployee1c.table_name} (employee_id, counting_guid, organization_inn, organization_kpp, hire_date, fire_date, deleted, user_id) VALUES #{emps1c}")
    end

    remove_index :resb_employees, name: 'index_resb_employees_INN_KPP_del'
    remove_index :resb_employees, name: 'index_resb_employees_INN_KPP'

    remove_column :resb_employees, :countingGUID
    remove_column :resb_employees, :organizationINN
    remove_column :resb_employees, :organizationKPP
    remove_column :resb_employees, :hireDate
    remove_column :resb_employees, :fireDate
  end

  def down
    add_column :resb_employees, :countingGUID, :string
    add_column :resb_employees, :organizationINN, :string
    add_column :resb_employees, :organizationKPP, :string
    add_column :resb_employees, :hireDate, :date
    add_column :resb_employees, :fireDate, :date

    add_index :resb_employees, [:organizationINN, :organizationKPP, :deleted], unique: false, name: 'index_resb_employees_INN_KPP_del'
    add_index :resb_employees, [:organizationINN, :organizationKPP], unique: false, name: 'index_resb_employees_INN_KPP'
  end
end