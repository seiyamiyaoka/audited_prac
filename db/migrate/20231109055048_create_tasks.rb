class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.boolean :done, default: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
