class CreateTaskAssigns < ActiveRecord::Migration[7.1]
  def change
    create_table :task_assigns do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :task_assigns, [:task_id, :user_id], unique: true
  end
end
