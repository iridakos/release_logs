class ReleaseLogConfiguration < ActiveRecord::Base
  include Redmine::I18n

  belongs_to :project
  belongs_to :release_log_queue

  scope :enabled, lambda { where(:enabled => true) }
  scope :for_project, lambda { |project_id| where(:project_id => project_id) }

  validates :project_id, :presence => true, :uniqueness => true
  validates :email_notification_recipients, :presence => { :unless => lambda { release_log_queue_id.present? } }, :multiple_email_addresses => true

  def enabled?
    enabled
  end

  def recipient_addresses
    self.email_notification_recipients.split(',')
  end
end
