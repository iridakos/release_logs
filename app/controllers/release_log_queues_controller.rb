class ReleaseLogQueuesController < ReleaseLogsBaseController
  unloadable

  include ReleaseLogsHelper

  before_action :authorize_global
  before_action :load_release_log_queue, :only => [:edit, :update, :destroy]

  def index
    @release_log_queues = ReleaseLogQueue.all
  end

  def new
    @release_log_queue = ReleaseLogQueue.new(:group_by_issue_type => true)
  end

  def create
    @release_log_queue = ReleaseLogQueue.new release_log_queue_params
    save_release_log_queue
  end

  def edit
  end

  def update
    @release_log_queue.assign_attributes release_log_queue_params
    save_release_log_queue
  end

  def destroy
    @release_log_queue.destroy
    flash[:notice] = release_logs_label_for(:queue_deleted, :queue_name => @release_log_queue.name)
    redirect_to release_log_queues_path
  end

  protected

  def release_log_queue_params
    if Rails::VERSION::MAJOR >= 4
      params.require(:release_log_queue).permit(:name, :title_template, :group_by_issue_type, :email_notification_recipients, :release_log_entry_categories_attributes => [:id, :title, :_destroy])
    else
      params[:release_log_queue]
    end
  end

  def load_release_log_queue
    @release_log_queue = ReleaseLogQueue.find(params[:id])
  end

  def save_release_log_queue
    new_record = @release_log_queue.new_record?

    if @release_log_queue.save
      flash[:notice] = release_logs_label_for(:"queue_#{new_record ? 'created' : 'updated'}", :queue_name => @release_log_queue.name)
      redirect_to release_log_queues_path
    else
      render new_record ? :new : :edit
    end
  end
end
