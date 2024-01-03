class ReleaseLogsBaseController < ApplicationController
  include ApplicationHelper

  helper :application

  include ReleaseLogsHelper
  helper ReleaseLogsHelper

  before_action :set_title

  protected

  def set_title
    html_title helpers.release_logs_label_for(:release_logs)
  end

end
