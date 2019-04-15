class RemoveUniqueuIndexFromReleaseLogEntries < ActiveRecord::Migration
  def change
    remove_index :release_log_entries, :column => [:release_log_id, :issue_id],:name => :rl_entr_log_issue_id
  end
end
