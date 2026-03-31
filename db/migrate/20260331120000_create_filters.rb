# frozen_string_literal: true

class CreateFilters < ActiveRecord::Migration[8.1]
  def change
    create_table :filters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :filters, [:user_id, :name], unique: true
  end
end
