class ReleaseLogPreviewsController < ReleaseLogsBaseController
  include ReleaseLogsHelper

  unloadable

  helper :release_logs

  before_filter :load_project
  before_filter :authorize
  before_filter :find_attachments
  before_filter :load_release_log

  layout false

  def release_log
  end

  def cancellation
  end

  def rollback
  end

  def publish_notification
    if @project.queue_release_log_enabled?
      @release_log.title = @release_log.queue_title_for_release_log
    end
  end

  def cancel_notification
    @release_log.canceller = User.current
    @release_log.cancelled_at = Time.current
  end

  def rollback_notification
    @release_log.rollbacker = User.current
    @release_log.rolled_back_at = Time.now
  end

  protected

  def load_project
    @project = Project.find_by_identifier(params[:project_id])
  end

  def load_release_log
    if params[:id]
      @release_log = ReleaseLog.find(params[:id])
      @attachments << @release_log.attachments.flatten
      @attachments.flatten!
    else
      @release_log = ReleaseLog.new
    end

    @release_log.assign_attributes(params[:release_log])
    @release_log.attachments = @attachments
    @release_log.project = @project
    @release_log.id ||= 0

    date = @release_log.released_at ||= Time.now
    @release_log.released_at = Time.now.change(:year => date.year, :month => date.month, :day => date.day, :hour => date.hour, :min => date.min)
  end
end
