class ReleaseLogPreviewsController < ReleaseLogsBaseController
  include ReleaseLogsHelper

  unloadable

  helper :release_logs

  before_action :load_project
  before_action :authorize
  before_action :find_attachments
  before_action :load_release_log

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

  def release_log_params
    if Rails::VERSION::MAJOR >= 4
      params.require(:release_log).permit(:title,
                                          :description,
                                          :send_email_notification,
                                          :release_upon_publish,
                                          :release_date,
                                          :release_hour,
                                          :release_minutes,
                                          :attachments,
                                          :rollback_reason,
                                          :cancellation_reason,
                                          :release_log_entries_attributes => [
                                            :id,
                                            :issue_id,
                                            :release_log_entry_category_id,
                                            :include_in_notification,
                                            :note
                                          ])
    else
      params[:release_log]
    end
  end

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

    @release_log.assign_attributes release_log_params
    @release_log.attachments = @attachments
    @release_log.project = @project
    @release_log.id ||= 0

    unless params[:release_date].blank? || params[:release_hour].blank? || params[:release_minutes].blank?
      release_date = Date.parse(params[:release_date]).in_time_zone
      release_date = User.current.time_zone.present? ? release_date.in_time_zone(User.current.time_zone) : (release_date.utc? ? release_date.localtime : release_date)
      release_date = release_date.change(:hour => params[:release_hour].to_i, :min => params[:release_minutes].to_i)
      @release_log.released_at = release_date
    end
  end
end
