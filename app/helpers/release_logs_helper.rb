module ReleaseLogsHelper
  # Calculates the the given hour to user's timezone hour.
  def user_timezone_hour_for(hour)
    timezone = User.current.time_zone
    timezone.present? ? Time.current.change(:hour => hour.to_i).in_time_zone(timezone).hour : hour
  end

  # Calculates the given hour to system's timezone hour.
  def system_timezone_hour_for(hour)
    Time.now.change(:hour => hour.to_i).in_time_zone.hour
  end

  # Resolves the literal of a release log's status.
  def release_log_status(release_log)
    release_logs_label_for(:"release_log_status_#{release_log.status}")
  end

  # Resolves the literal describing the release status of an issue.
  def issue_release_verb(release_log)
    status =  release_log.status

    case status
      when ReleaseLog::PENDING_RELEASE_STATUS
        release_logs_label_for(:will_be_released)
      when ReleaseLog::RELEASED_STATUS, ReleaseLog::ROLLED_BACK_STATUS
        release_logs_label_for(:was_released)
      when ReleaseLog::CANCELLED_STATUS
        release_logs_label_for(:was_to_be_released)
    end
  end

  # Resolves the literal describing a releases' failed status.
  def issue_failed_release_info(release_log)
    status = release_log.status
    case status
      when ReleaseLog::ROLLED_BACK_STATUS
        " #{release_logs_label_for(:issue_rollback_failed_release)}".html_safe
      when ReleaseLog::CANCELLED_STATUS
        " #{release_logs_label_for(:issue_cancel_failed_release)}".html_safe
      else
        ''
    end
  end

  # Filters nested attributes' errors messages out of a models errors.
  def filtered_error_messages_for(object_name, options = {})
    if options[:exclude].present?
      exclusions = options[:exclude].is_a?(Array) ? options[:exclude].map(&:to_s).join('|') : options[:exclude].to_s
      exclusion_regex = /(#{exclusions})\..*/
    end

    html = ""
    object = object_name.is_a?(String) ? instance_variable_get("@#{object_name}") : object_name
    errors = (exclusion_regex.present? ? object.errors.full_messages.select{|error_message| !(error_message =~ exclusion_regex) } : object.errors.full_messages).flatten
    if errors.any?
      html << "<div id='errorExplanation'><ul>\n"
      errors.each do |error|
        html << "<li>#{h error}</li>\n"
      end
      html << "</ul></div>\n"
    end
    html.html_safe
  end

  # Removes headings from the default textilizable plugin.
  def release_log_textilizable(object, attribute, attachments)
    textilizable object, attribute, :attachments => attachments, :headings => false
  end

  # Translates an entry in the release logs i18n world.
  def release_logs_label_for(entry, options = {})
    l("release_logs_label_#{entry.downcase}", options)
  end

  # Translates a help entry in the release logs i18n world.
  def release_logs_help_for(entry, options = {})
    l("release_logs_help_#{entry.downcase}", options)
  end
end
