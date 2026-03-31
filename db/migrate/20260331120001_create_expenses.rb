# frozen_string_literal: true

class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :filter, null: true, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :spent_on, null: false

      t.timestamps
    end

    add_index :expenses, [:user_id, :spent_on]
  end
end
