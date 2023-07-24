# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee, type: :model do
  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:department) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_presence_of(:date_of_employment) }
    it { should validate_numericality_of(:salary_cents) }
    it { is_expected.to monetize(:salary) }
  end
end
