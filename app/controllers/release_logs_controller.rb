class ReleaseLogsController < ReleaseLogsBaseController
  include AttachmentsHelper, ReleaseLogsHelper

  DEFAULT_LIMIT = 10

  helper :attachments
  helper :release_logs

  helper ReleaseLogsHelper

  before_action :load_project
  before_action :authorize
  before_action :load_configuration
  before_action :load_release_log, :only => [:edit, :show, :update, :destroy, :clone, :send_notification]

  def index
    @limit = params[:limit] || DEFAULT_LIMIT
    @release_log_count = ReleaseLog.for_project(@project).latest.count
    @release_log_pages = Paginator.new @release_log_count, @limit, params['page']
    @offset ||= @release_log_pages.offset
    @release_logs = ReleaseLog.for_project(@project).latest.offset(@offset).limit(@limit)
  end

  def new
    @release_log = ReleaseLog.new(:project_id => @project.id,
                                  :send_email_notification => true,
                                  :release_upon_publish => true)
  end

  def create
    @release_log = ReleaseLog.new release_log_params
    save_release_log
  end

  def show
  end

  def edit
  end

  def clone
    release_log = @release_log
    @release_log = ReleaseLog.new :title => release_log.title,
                                  :description => release_log.description,
                                  :send_email_notification => release_log.send_email_notification,
                                  :release_upon_publish => release_log.release_upon_publish,
                                  :released_at => release_log.released_at

    @release_log.release_log_entries =  release_log.release_log_entries.map do |entry|
      ReleaseLogEntry.new :issue_id => entry.issue_id,
                          :include_in_notification => entry.include_in_notification,
                          :release_log_entry_category_id => entry.release_log_entry_category_id,
                          :note => entry.note
    end

    render :new
  end

  def update
    @release_log.assign_attributes release_log_params

    if params[:cancel]
      cancel_release_log
    elsif params[:rollback]
      rollback_release_log
    else
      save_release_log
    end
  end

  def destroy
    @release_log.destroy
    flash[:notice] = release_logs_label_for(:release_log_deleted, :project => @project.name)
    redirect_to release_logs_path
  end

  def send_notification
    case params[:type]
      when ReleaseLogNotification::TYPE_ROLLBACK,ReleaseLogNotification::TYPE_CANCEL,ReleaseLogNotification::TYPE_SUCCESSFUL_RELEASE,ReleaseLogNotification::TYPE_PUBLISH
        type = "ReleaseLogNotification::TYPE_#{params[:type].upcase}".constantize
      else
        redirect_to release_logs_path and return
    end

    if type == ReleaseLogNotification::TYPE_SUCCESSFUL_RELEASE && @release_log.pending_release?
      @release_log.title = @release_log.queue_title_for_release_log if @project.queue_release_log_enabled?
      @release_log.released_at = Time.now
      @release_log.save
    end

    if send_release_log_notification(type)
      flash[:notice] = release_logs_label_for(:notification_sent)
    end

    redirect_to release_log_path(@release_log, :project_id => @project.identifier)
  end

  protected

  def save_release_log
    new_record = @release_log.new_record?
    should_publish = params[:publish] && !@release_log.published?

    unless params[:release_date].blank? || params[:release_hour].blank? || params[:release_minutes].blank?
      release_date = Date.parse(params[:release_date]).in_time_zone
      release_date = User.current.time_zone.present? ? release_date.in_time_zone(User.current.time_zone) : (release_date.utc? ? release_date.localtime : release_date)
      release_date = release_date.change(:hour => params[:release_hour].to_i, :min => params[:release_minutes].to_i)
      @release_log.released_at = release_date
    end

    @release_log.project = @project
    @release_log.user_id ||= User.current.id
    @release_log.save_attachments(params[:attachments])

    @release_log.release_log_entries.each do |release_log_entry|
      release_log_entry.release_log = @release_log
    end

    @release_log.title = @release_log.queue_title_for_release_log if @project.queue_release_log_enabled?

    if should_publish
      @release_log.publish(User.current)
    end

    if @release_log.save
      flash[:notice] = release_logs_label_for(:"release_log_#{should_publish ? 'published' : (new_record ? 'created' : 'updated') }",
                                              :title => @release_log.title,
                                              :project => @project.name)

      send_release_log_notification(ReleaseLogNotification::TYPE_PUBLISH) if should_publish && @release_log.send_email_notification?
      redirect_to release_log_path(@release_log, :project_id => @project.identifier)
    else
      if should_publish
        @release_log.published_at = nil
        @release_log.released_at = nil if @release_log.release_upon_publish
      end
      render :new
    end
  end

  def rollback_release_log
    @release_log.rollbacker = User.current
    @release_log.rolled_back_at = Time.now
    @release_log.save_attachments(params[:attachments])

    if @release_log.save && (!@release_log.send_email_notification? || send_release_log_notification(ReleaseLogNotification::TYPE_ROLLBACK))
      flash[:notice] = release_logs_label_for(:successful_rollback, :title => @release_log.title)
      redirect_to release_log_path(@release_log, :project_id => @project.identifier)
    else
      @release_log.rollbacker = nil
      @release_log.rolled_back_at = nil
      @show_rollback_form = true
      render :show
    end
  end

  def cancel_release_log
    @release_log.canceller = User.current
    @release_log.cancelled_at = Time.now
    @release_log.save_attachments(params[:attachments])

    if @release_log.save && (!@release_log.send_email_notification? || send_release_log_notification(ReleaseLogNotification::TYPE_CANCEL))
      flash[:notice] = release_logs_label_for(:successful_cancellation, :title => @release_log.title)
      redirect_to release_log_path(@release_log, :project_id => @project.identifier)
    else
      @release_log.canceller = nil
      @release_log.cancelled_at = nil
      @show_cancellation_form = true
      render :show
    end
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

  def send_release_log_notification(type)
    
    @release_log_configuration = @release_log.project.release_log_configuration
    @release_log_queue = @release_log_configuration.release_log_queue
    recipient_addresses = @release_log_configuration.recipient_addresses
    recipient_addresses << @release_log_queue.recipient_addresses if @release_log_queue.present?
    recipient_addresses = recipient_addresses.flatten.uniq
    logger.info "Recipient Addresses: #{recipient_addresses}"
    for email in recipient_addresses 
      logger.info "looking for email_addresses with email: #{email.strip}"
      found_emails = EmailAddress.where(["address = ?", email.strip])
      for found_email in found_emails
        logger.info "looking for users with with user_id: #{found_email.user_id}"
        found_users = User.where(["id = ?", found_email.user_id])
        message = ReleaseLogMailer.send(:"release_log_#{type}_notification", found_users.first, @release_log)
        message.deliver_later
      end
    end
    #message = ReleaseLogMailer.release_log_successful_release_notification(users.first, @release_log)
    
    #ReleaseLogMailer.deliver_release_log_successful_release_notification(@release_log)

    notification = @release_log.release_log_notifications.build(:notification_type => type, :sent_at => Time.now)
    notification.release_log_queue_id = @project.release_log_configuration.release_log_queue.id if @project.queue_release_log_enabled?
    notification.message_id = message.message_id 
    notification.title = @release_log.title
    notification.save!
    true
  rescue => e
    flash[:error] = release_logs_label_for(:notification_failed)
    logger.error e.message
    logger.error e.backtrace.join("\n")
    false
  end

  def load_project
    @project = Project.find_by_identifier(params[:project_id])
  end

  def load_configuration
    @release_log_configuration = @project.release_log_configuration

    unless @release_log_configuration.present?
      render :error , :locals => { :message => release_logs_label_for(:no_configuration, :project => @project.name) } and return
    end

    unless @release_log_configuration.enabled?
      render :error , :locals => { :message => release_logs_label_for(:disabled_configuration, :project => @project.name) }
    end
  end

  def load_release_log
    @release_log = ReleaseLog.find(params[:id])
  end
end
