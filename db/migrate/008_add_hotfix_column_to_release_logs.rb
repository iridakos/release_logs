class AddHotfixColumnToReleaseLogs < ActiveRecord::Migration
  def change
    add_column :release_logs, :hotfix, :boolean, :default => false
  end
end
