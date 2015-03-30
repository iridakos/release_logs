module ReleaseLogs
  class Patcher
    def self.register_patches
      Project.class_eval do
        has_one :release_log_configuration, :inverse_of => :project, :dependent => :destroy
        has_many :release_logs, :inverse_of => :project, :dependent => :destroy

        def release_log_enabled?
          release_log_configuration.present? && release_log_configuration.enabled?
        end

        def queue_release_log_enabled?
          release_log_enabled? && release_log_configuration.release_log_queue.present?
        end
      end

      User.class_eval do
        has_many :release_logs, :inverse_of => :user, :dependent => :destroy
      end

      IssuesController.class_eval do
        include ReleaseLogsHelper

        helper :release_logs
      end

      ApplicationHelper.class_eval do
        include ReleaseLogsHelper
      end
    end
  end
end
