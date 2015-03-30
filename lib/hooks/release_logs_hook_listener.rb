class ReleaseLogsHookListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    stylesheet_link_tag 'release-logs', :plugin => 'release_logs'
  end

  render_on :view_issues_show_description_bottom, :partial => 'hooks/issue_hook'
end
