class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :title, null: false
      t.string :department, null: false
      t.date :date_of_birth, null: false
      t.date :date_of_employment, null: false
      t.timestamps
    end
  end
end
