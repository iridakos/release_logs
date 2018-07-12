class AddVersionToReleaseLog < ActiveRecord::Migration
  def change
    add_column :release_logs, :version_id, :integer
  end
end
