class ReleaseLogEntryCategory < ActiveRecord::Base
  include Redmine::I18n

  has_many :release_log_entries, :inverse_of => :release_log_entry_category, :dependent => :nullify
  belongs_to :release_log_queue, :inverse_of => :release_log_entry_categories

  validates :title, :presence => true
end
