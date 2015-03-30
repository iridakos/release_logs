class CreateReleaseLogNotifications < ActiveRecord::Migration
  def change
    create_table :release_log_notifications do |t|
      t.integer :release_log_id, :null => false
      t.string :notification_type, :null => false
      t.integer :release_log_queue_id
      t.string :message_id, :null => false
      t.string :title, :null => false
      t.datetime :sent_at, :null => false
      t.text :note
    end

    add_index :release_log_notifications, :release_log_id, :name => :rl_not_log_id
    add_index :release_log_notifications, :release_log_queue_id, :name => :rl_not_queue_id
  end
end
