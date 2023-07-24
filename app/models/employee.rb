# frozen_string_literal: true

class Employee < ApplicationRecord
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :department, presence: true, length: { maximum: 255 }
  validates :date_of_birth, presence: true
  validates :date_of_employment, presence: true

  monetize :salary_cents, allow_nil: false, numericality: { greater_than_or_equal_to: 0 }

  private

  def self.ransackable_attributes(auth_object = nil)
    %w(department title salary_cents)
  end

  def self.ransortable_attributes(auth_object = nil)
    %w(date_of_employment salary_cents)
  end
end
