class ReleaseLogConfiguration < ActiveRecord::Base
  include Redmine::I18n

  unloadable

  belongs_to :project, :inverse_of => :release_log_configuration
  belongs_to :release_log_queue

  scope :enabled, lambda { where(:enabled => true) }
  scope :for_project, lambda { |project_id| where(:project_id => project_id) }

  validate :valid_email_notification_recipients
  validates :project_id, :presence => true, :uniqueness => true
  validates :email_notification_recipients, :presence => true

  def enabled?
    enabled
  end

  def recipients
    self.email_notification_recipients.split(',')
  end

  protected

  def valid_email_notification_recipients
    emails = self.email_notification_recipients.split(',')
    emails.each do |email|
      self.errors[:email_notification_recipients] << ": #{email} is not a valid email" unless email.strip =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    end
  end
end
