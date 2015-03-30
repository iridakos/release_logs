class ReleaseLogQueuesController < ReleaseLogsBaseController
  unloadable

  include ReleaseLogsHelper

  before_filter :authorize_global
  before_filter :load_release_log_queue, :only => [:edit, :update, :destroy]

  def index
    @release_log_queues = ReleaseLogQueue.all
  end

  def new
    @release_log_queue = ReleaseLogQueue.new(:group_by_issue_type => true)
  end

  def create
    @release_log_queue = ReleaseLogQueue.new(params[:release_log_queue])
    save_release_log_queue
  end

  def edit
  end

  def update
    @release_log_queue.assign_attributes params[:release_log_queue]
    save_release_log_queue
  end

  def destroy
    @release_log_queue.destroy
    flash[:notice] = release_logs_label_for(:queue_deleted, :queue_name => @release_log_queue.name)
    redirect_to release_log_queues_path
  end

  protected

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
