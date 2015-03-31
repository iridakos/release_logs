class CreateReleaseLogQueues < ActiveRecord::Migration
  def change
    create_table :release_log_queues do |t|
      t.string :name, :null => false
      t.string :title_template
      t.boolean :group_by_issue_type
      t.text :email_notification_recipients, :null => false

      t.timestamps
    end

    add_index :release_log_queues, :name, :unique => true, :name => :rl_queue_name
  end
end
