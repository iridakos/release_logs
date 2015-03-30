class ReleaseLogsBaseController < ApplicationController
  include ApplicationHelper
  unloadable

  helper :application

  before_filter :set_title

  protected

  def set_title
    html_title release_logs_label_for(:release_logs)
  end

end
