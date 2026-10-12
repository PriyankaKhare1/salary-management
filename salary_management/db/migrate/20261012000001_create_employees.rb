class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :department, null: false
      t.string :designation, null: false
      t.string :country, null: false
      t.string :currency, null: false

      t.timestamps
    end

    add_index :employees, :email, unique: true
    add_index :employees, :department
    add_index :employees, :country
    add_index :employees, :designation
  end
end
