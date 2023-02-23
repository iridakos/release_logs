class ReleaseLogsHomeController < ReleaseLogsBaseController
  include ReleaseLogsHelper

  unloadable

  DEFAULT_LIMIT = 10

  helper :release_logs

  before_action :authorize_global

  def index
    @release_logs = ReleaseLog.latest

    @limit = params[:limit] || DEFAULT_LIMIT
    @release_log_count = ReleaseLog.latest.count
    @release_log_pages = Paginator.new @release_log_count, @limit, params['page']
    @offset ||= @release_log_pages.offset
    @release_logs = ReleaseLog.latest.offset(@offset).limit(@limit)
  end

  def search
    @projects = Project.all
    @queues = ReleaseLogQueue.all
    @release_log_query = ReleaseLogs::Searches::ReleaseLogQuery.new(params[:q] || {})

    if params[:query] == 'true' && @release_log_query.valid?
      @release_log_count  = @release_log_query.execute.count
      @limit = params[:limit] || DEFAULT_LIMIT

      @release_log_pages = Paginator.new @release_log_count, @limit, params['page']
      @offset ||= @release_log_pages.offset
      @release_logs = @release_log_query.execute(@offset, @limit)
      flash.now[:warning] = release_logs_label_for(:no_results_found) unless @release_logs.present?
    end
  end
end
