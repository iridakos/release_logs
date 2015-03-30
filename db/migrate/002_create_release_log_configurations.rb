class CreateReleaseLogConfigurations < ActiveRecord::Migration
  def change
    create_table :release_log_configurations do |t|
      t.integer :project_id, :null => false
      t.boolean :enabled, :default => true
      t.text :email_notification_recipients, :null => false
      t.integer :release_log_queue_id

      t.timestamps
    end

    add_index :release_log_configurations, :project_id, :unique => true, :name => :rl_conf_project_id
    add_index :release_log_configurations, :release_log_queue_id, :name => :rl_conf_queue_id
  end
end
