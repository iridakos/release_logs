require 'monkey/patcher'

ActiveSupport::Reloader.to_prepare do
  ReleaseLogs::Patcher.register_patches
end

Redmine::Plugin.register :release_logs do
  name 'Release Logs plugin'
  author 'Lazarus Lazaridis'
  description 'Redmine plugin for managing project releases'
  version '1.0.0'
  url 'https://github.com/iridakos/release_logs'
  author_url 'http://www.arubystory.com'
  requires_redmine :version_or_higher => '2.5.2'

  permission :manage_release_log_configurations, :release_log_configurations => [:index, :new, :create, :edit, :update, :destroy]
  permission :manage_release_log_queues, :release_log_queues => [:index, :new, :create, :edit, :update, :destroy]

  permission :view_global_release_logs, :release_logs_home => [:index, :search]

  menu :top_menu, :release_logs, { :controller => 'release_logs_home', :action => 'index' }, :caption => 'Release logs', :if => lambda { |project| User.current.allowed_to_globally?(:view_global_release_logs, {}) }

  menu :admin_menu, :release_log_configurations, { :controller => 'release_log_configurations', :action => :index }, :caption => 'Release log configurations', :html => { :class => 'release-logs' }
  menu :admin_menu, :release_log_queues, { :controller => 'release_log_queues', :action => 'index' }, :caption => 'Release log queues', :html => { :class => 'release-log-queues' }, :after => :release_logs

  project_module :release_logs do
    permission :view_project_release_logs,
               :release_logs => [:index, :show]

    permission :manage_project_release_logs,
               :release_logs => [:new, :create, :edit, :update, :destroy, :clone, :send_notification],
               :release_log_previews => [:release_log,
                                         :publish_notification,
                                         :cancel_notification,
                                         :rollback_notification,
                                         :cancellation,
                                         :rollback]

    menu :project_menu, :release_logs, { :controller => 'release_logs', :action => 'index' }, :caption => 'Release logs', :after => :activity, :param => :project_id
  end
end

require 'hooks/release_logs_hook_listener'
require 'release_logs/searches/release_log_query'
