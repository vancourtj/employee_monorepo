class AddSalaryToEmployees < ActiveRecord::Migration[7.0]
  def change
    add_monetize :employees, :salary, currency: { present: false }
  end
end
