class ReleaseLogEntry < ActiveRecord::Base
  include Redmine::I18n

  unloadable

  belongs_to :issue
  belongs_to :release_log, :inverse_of => :release_log_entries
  belongs_to :release_log_entry_category, :inverse_of => :release_log_entries

  validates :issue_id, :uniqueness => { :scope => :release_log_id }
  validates :note, :presence => true
  validate :valid_configuration

  scope :for_issue, lambda { |issue| includes(:release_log).where('release_log_entries.issue_id = ? and release_logs.published_at is not null', issue.id).order('release_logs.released_at desc') }

  protected

  def valid_configuration
    issue = Issue.find_by_id(self.issue_id) if self.issue_id
    project = Project.find(self.release_log.project_id)

    if issue_id.present? && issue.blank?
      errors.add(:issue_id, :release_log_invalid_issue_id)
    elsif issue_id.present? && !(issue.project.is_or_is_ancestor_of?(project) || issue.project.is_descendant_of?(project))
      errors.add(:issue_id, :release_log_project_invalid_issue)
    end

    if project.queue_release_log_enabled? && !project.release_log_configuration.release_log_queue.group_by_issue_type && self.release_log_entry_category_id.blank?
      errors.add(:release_log_entry_category_id, :blank)
    end
  end
end

Issue.class_eval do
  has_many :release_log_enties, :inverse_of => :issue, :dependent => :nullify, :class_name => 'ReleaseLogEntry'
end
