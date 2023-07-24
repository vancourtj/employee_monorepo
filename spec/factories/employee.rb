FactoryBot.define do
  factory :employee, class: Employee do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    title { Faker::Job.title }
    department { Faker::Company.department }
    date_of_birth { Faker::Date.between(from: '1900-01-01', to: 2.days.ago) }
    date_of_employment { Faker::Date.between(from: date_of_birth, to: Date.current) }
    salary { (SecureRandom.random_number(1e6) + 1e3).to_i }
  end
end
