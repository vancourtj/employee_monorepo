# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeSerializer, type: :serializer do
  let(:employee) { create(:employee) }
  let(:serializer) { described_class.new(employee) }
  let(:subject) { serializer.serializable_hash }

  it "serializes the employee" do
    expect(subject).to eq(
      {
        id: employee.id,
        first_name: employee.first_name,
        last_name: employee.last_name,
        title: employee.title,
        department: employee.department,
        date_of_birth: employee.date_of_birth,
        date_of_employment: employee.date_of_employment,
        salary: employee.salary.amount
      }
    )
  end
end
