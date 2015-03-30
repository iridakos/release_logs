class CreateReleaseLogEntryCategories < ActiveRecord::Migration
  def change
    create_table :release_log_entry_categories do |t|
      t.integer :release_log_queue_id, :null => false
      t.string :title
    end

    add_index :release_log_entry_categories, :release_log_queue_id, :name => :rl_entr_cat_queue_id
  end
end
