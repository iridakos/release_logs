class ReleaseLogNotification < ActiveRecord::Base
  include Redmine::I18n

  TYPE_PUBLISH = 'publish'
  TYPE_SUCCESSFUL_RELEASE = 'successful_release'
  TYPE_ROLLBACK = 'rollback'
  TYPE_CANCEL = 'cancel'

  belongs_to :release_log, :inverse_of => :release_log_notifications
  belongs_to :release_log_queue, :inverse_of => :release_log_notifications

  scope :for_queue_and_title, lambda { |release_log|
    where(:release_log_queue_id => release_log.project.release_log_configuration.release_log_queue.id, :title => release_log.title).order('sent_at desc')
  }

  validates :notification_type, :inclusion => [TYPE_PUBLISH, TYPE_SUCCESSFUL_RELEASE, TYPE_ROLLBACK, TYPE_CANCEL]
end
