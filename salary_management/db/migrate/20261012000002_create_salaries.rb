class CreateSalaries < ActiveRecord::Migration[7.1]
  def change
    create_table :salaries do |t|
      t.references :employee, null: false, foreign_key: true, index: { unique: true }
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.date :effective_date, null: false

      t.timestamps
    end
  end
end
