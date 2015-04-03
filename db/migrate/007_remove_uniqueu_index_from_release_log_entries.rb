class RemoveUniqueuIndexFromReleaseLogEntries < ActiveRecord::Migration
  def change
    remove_index :release_log_entries, :name => :rl_entr_log_issue_id
  end
end
