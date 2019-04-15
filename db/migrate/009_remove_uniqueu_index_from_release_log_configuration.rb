class RemoveUniqueuIndexFromReleaseLogConfiguration < ActiveRecord::Migration
  def change
    remove_index :release_log_configurations, :column => :project_id, :name => :rl_conf_project_id
  end
end
