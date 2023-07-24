# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::EmployeesController, type: :request do
  let!(:employee1) do
    create(:employee, first_name: "Thomas", title: "Manager", department: "State", salary: 100,
                      date_of_employment: Date.new(2022, 01, 01))
  end
  let!(:employee2) do
    create(:employee, first_name: "Alexander", title: "Director", department: "Treasury", salary: 99,
                      date_of_employment: Date.new(2021, 01, 01))
  end
  let!(:employee3) do
    create(:employee, first_name: "James", title: "Director", department: "Defense", salary: 101,
                      date_of_employment: Date.new(2020, 01, 01))
  end

  describe "#index" do
    it "returns all employees and ok status" do
      get api_v1_employees_path

      result = JSON.parse(response.body)

      expect(result.size).to eq(3)
      expect(response.status).to eq(200)
    end

    it "defaults the sort to date_of_employment asc" do
      get api_v1_employees_path

      result = JSON.parse(response.body)

      expect(result[0]["id"]).to eq(employee3.id)
      expect(result[1]["id"]).to eq(employee2.id)
      expect(result[2]["id"]).to eq(employee1.id)
    end

    context "search" do
      it "ignores non-whitelisted params" do
        get api_v1_employees_path, params: { query: { first_name_eq: "Thomas" } }

        result = JSON.parse(response.body)

        expect(result.size).to eq(3)
      end

      it "can match department" do
        get api_v1_employees_path, params: { query: { department_eq: "State" } }

        result = JSON.parse(response.body)

        expect(result.size).to eq(1)
        expect(result[0]["id"]).to eq(employee1.id)
      end

      it "can match title" do
        get api_v1_employees_path, params: { query: { title_eq: "Director" } }

        result = JSON.parse(response.body)

        expect(result.size).to eq(2)
        expect(result[0]["id"]).to eq(employee3.id)
        expect(result[1]["id"]).to eq(employee2.id)
      end

      it "can match salary_cents" do
        get api_v1_employees_path, params: { query: { salary_cents_eq: 10000 } }

        result = JSON.parse(response.body)

        expect(result.size).to eq(1)
        expect(result[0]["id"]).to eq(employee1.id)
      end

      it "can search < salary_cents" do
        get api_v1_employees_path, params: { query: { salary_cents_lt: 10000 } }

        result = JSON.parse(response.body)

        expect(result.size).to eq(1)
        expect(result[0]["id"]).to eq(employee2.id)
      end

      it "can search <= salary_cents" do
        get api_v1_employees_path, params: { query: { salary_cents_lteq: 10000 } }

        result = JSON.parse(response.body)

        expect(result.size).to eq(2)
        expect(result[0]["id"]).to eq(employee2.id)
        expect(result[1]["id"]).to eq(employee1.id)
      end

      it "can search > salary_cents" do
        get api_v1_employees_path, params: { query: { salary_cents_gt: 10000 } }

        result = JSON.parse(response.body)

        expect(result.size).to eq(1)
        expect(result[0]["id"]).to eq(employee3.id)
      end

      it "can search >= salary_cents" do
        get api_v1_employees_path, params: { query: { salary_cents_gteq: 10000 } }

        result = JSON.parse(response.body)

        expect(result.size).to eq(2)
        expect(result[0]["id"]).to eq(employee3.id)
        expect(result[1]["id"]).to eq(employee1.id)
      end
    end

    context "sort" do
      it "ignores non-whitelisted params" do
        get api_v1_employees_path, params: { sort: { first_name: "asc" } }

        result = JSON.parse(response.body)

        expect(result[0]["id"]).to eq(employee3.id)
        expect(result[1]["id"]).to eq(employee2.id)
        expect(result[2]["id"]).to eq(employee1.id)
      end

      it "sorts on salary_cents asc" do
        get api_v1_employees_path, params: { sort: { salary_cents: "asc" } }

        result = JSON.parse(response.body)

        expect(result[0]["id"]).to eq(employee2.id)
        expect(result[1]["id"]).to eq(employee1.id)
        expect(result[2]["id"]).to eq(employee3.id)
      end

      it "sorts on salary_cents desc" do
        get api_v1_employees_path, params: { sort: { salary_cents: "desc" } }

        result = JSON.parse(response.body)

        expect(result[0]["id"]).to eq(employee3.id)
        expect(result[1]["id"]).to eq(employee1.id)
        expect(result[2]["id"]).to eq(employee2.id)
      end

      it "sorts on date_of_employment asc" do
        get api_v1_employees_path, params: { sort: { date_of_employment: "asc" } }

        result = JSON.parse(response.body)

        expect(result[0]["id"]).to eq(employee3.id)
        expect(result[1]["id"]).to eq(employee2.id)
        expect(result[2]["id"]).to eq(employee1.id)
      end

      it "sorts on date_of_employment desc" do
        get api_v1_employees_path, params: { sort: { date_of_employment: "desc" } }

        result = JSON.parse(response.body)

        expect(result[0]["id"]).to eq(employee1.id)
        expect(result[1]["id"]).to eq(employee2.id)
        expect(result[2]["id"]).to eq(employee3.id)
      end
    end

    it "can search and sort" do
      get api_v1_employees_path, params: { query: { title_eq: "Director" }, sort: { salary_cents: "desc" } }

      result = JSON.parse(response.body)

      expect(result.size).to eq(2)
      expect(result[0]["id"]).to eq(employee3.id)
      expect(result[1]["id"]).to eq(employee2.id)
    end
  end

  describe "#show" do
    context "when the employee exists" do
      it "returns the employee and ok status" do
        get api_v1_employee_path(employee1)

        result = JSON.parse(response.body)

        expect(result["id"]).to eq(employee1.id)
        expect(response.status).to eq(200)
      end
    end

    context "when the employee does not exist" do
      it "returns error message and not_found status" do
        get api_v1_employee_path("123")

        result = JSON.parse(response.body)["error"]

        expect(result).to eq("Employee with id 123 not found")
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#create" do
    context "when all params are valid" do
      let(:params) do
        {
          data: {
            first_name: "George",
            last_name: "Washington",
            title: "POTUS",
            department: "Executive Branch",
            date_of_birth: Date.new(1732, 02, 22),
            date_of_employment: Date.new(1789, 04, 30),
            salary_cents: 2500000
          }
        }
      end

      it "successfully creates a new employee" do
        expect { post api_v1_employees_path, params: params }.to change(Employee, :count).by(1)
      end

      it "returns the employee data and created status" do
        post api_v1_employees_path, params: params

        result = JSON.parse(response.body)

        expect(result["first_name"]).to eq("George")
        expect(result["last_name"]).to eq("Washington")
        expect(result["title"]).to eq("POTUS")
        expect(result["department"]).to eq("Executive Branch")
        expect(result["date_of_birth"].to_date).to eq(Date.new(1732, 02, 22))
        expect(result["date_of_employment"].to_date).to eq(Date.new(1789, 04, 30))
        expect(result["salary"].to_i).to eq(25000)
        expect(response.status).to eq(201)
      end
    end

    context "when the params are invalid" do
      let(:params) do
        {
          data: {
            last_name: "Washington",
            title: "POTUS",
            department: "Executive Branch",
            date_of_birth: Date.new(1732, 02, 22),
            date_of_employment: Date.new(1789, 04, 30),
            salary_cents: 2500000
          }
        }
      end

      it "does not create an employee" do
        expect { post api_v1_employees_path, params: params }.to change(Employee, :count).by(0)
      end

      it "returns error message and unprocessable_entity" do
        post api_v1_employees_path, params: params

        result = JSON.parse(response.body)["error"]

        expect(result).to eq("Unable to create employee.")
        expect(response.status).to eq(422)
      end
    end
  end

  describe "#update" do
    context "when all params are valid" do
      let(:employee) { create(:employee, first_name: "hello", last_name: "there", title: "general") }
      let(:params) do
        {
          data: {
            first_name: "George",
            last_name: "Washington"
          }
        }
      end

      it "updates only the specified attributes on the employee" do
        expect(employee.first_name).to eq("hello")
        expect(employee.last_name).to eq("there")
        expect(employee.title).to eq("general")

        put api_v1_employee_path(employee), params: params

        result = JSON.parse(response.body)

        employee.reload

        expect(employee.first_name).to eq("George")
        expect(employee.last_name).to eq("Washington")
        expect(employee.title).to eq("general")
      end

      it "returns the updated employee data and ok status" do
        put api_v1_employee_path(employee), params: params

        result = JSON.parse(response.body)

        expect(result["first_name"]).to eq("George")
        expect(result["last_name"]).to eq("Washington")
        expect(result["title"]).to eq("general")
        expect(response.status).to eq(200)
      end
    end

    context "when the params are invalid" do
      let(:employee) { create(:employee, first_name: "hello") }
      let(:params) do
        {
          data: {
            first_name: "",
          }
        }
      end

      it "does not update the employee" do
        expect(employee.first_name).to eq("hello")

        put api_v1_employee_path(employee), params: params

        employee.reload

        expect(employee.first_name).to eq("hello")
      end

      it "returns error message and unprocessable_entity" do
        put api_v1_employee_path(employee), params: params

        result = JSON.parse(response.body)["error"]

        expect(result).to eq("Unable to update employee.")
        expect(response.status).to eq(422)
      end
    end

    context "when the employee does not exist" do
      it "returns error message and not_found status" do
        put api_v1_employee_path("123")

        result = JSON.parse(response.body)["error"]

        expect(result).to eq("Employee with id 123 not found")
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#destroy" do
    context "when the employee is successfully destroyed" do
      let!(:employee) { create(:employee) }

      it "deletes the employee" do
        expect { delete api_v1_employee_path(employee) }.to change(Employee, :count).by(-1)

        expect(Employee.all).not_to include(employee)
      end

      it "returns a success message and ok status" do
        delete api_v1_employee_path(employee)

        result = JSON.parse(response.body)["message"]

        expect(result).to eq("Employee record successfully deleted")
        expect(response.status).to eq(200)
      end
    end

    context "when the employee is not successfully destroyed" do
      let(:employee) { create(:employee) }

      before do
        allow_any_instance_of(Employee).to receive(:destroy).and_return(false)
      end

      it "returns error message and unprocessable_entity" do
        delete api_v1_employee_path(employee)

        result = JSON.parse(response.body)["error"]

        expect(result).to eq("Unable to delete employee.")
        expect(response.status).to eq(422)
      end
    end

    context "when the employee does not exist" do
      it "returns error message and not_found status" do
        delete api_v1_employee_path("123")

        result = JSON.parse(response.body)["error"]

        expect(result).to eq("Employee with id 123 not found")
        expect(response.status).to eq(404)
      end
    end
  end
end
