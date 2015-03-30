class CreateReleaseLogs < ActiveRecord::Migration
  def change
    create_table :release_logs do |t|
      t.string :title, :null => false
      t.text :description

      t.boolean :send_email_notification

      t.boolean :release_upon_publish

      t.integer :project_id, :null => false
      t.integer :user_id, :null => false

      t.datetime :published_at
      t.integer :published_by

      t.datetime :released_at
      t.integer :released_by

      t.datetime :rolled_back_at
      t.text :rollback_reason
      t.integer :rolled_back_by

      t.datetime :cancelled_at
      t.text :cancellation_reason
      t.integer :cancelled_by

      t.timestamps
    end

    add_index :release_logs, :project_id, :name => :rl_project_id
    add_index :release_logs, :released_at, :name => :rl_released_at
    add_index :release_logs, :published_at, :name => :rl_published_at
    add_index :release_logs, :rolled_back_at, :name => :rl_rolled_at
    add_index :release_logs, :cancelled_at, :name => :rl_cancelled_at
  end
end
