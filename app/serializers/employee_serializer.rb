# frozen_string_literal: true

class EmployeeSerializer < ActiveModel::Serializer
  attributes :id,
             :first_name,
             :last_name,
             :title,
             :department,
             :date_of_birth,
             :date_of_employment,
             :salary

  def salary
    object.salary.amount
  end
end
