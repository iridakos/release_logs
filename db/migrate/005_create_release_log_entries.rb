class CreateReleaseLogEntries < ActiveRecord::Migration
  def change
    create_table :release_log_entries do |t|
      t.text :note
      t.integer :release_log_id, :null => false
      t.integer :issue_id
      t.boolean :include_in_notification
      t.integer :release_log_entry_category_id

      t.timestamps
    end

    add_index :release_log_entries, :issue_id, :name => :rl_entr_issue_id
    add_index :release_log_entries, [:release_log_id, :issue_id], :unique => true, :name => :rl_entr_log_issue_id
    add_index :release_log_entries, :release_log_id, :name => :rl_entr_log_id
    add_index :release_log_entries, [:release_log_id, :include_in_notification], :name => :rl_entr_log_not_id
    add_index :release_log_entries, :release_log_entry_category_id, :name => :rl_entr_categ_id
  end
end
