class ReleaseLogMailer < Mailer

  helper :release_logs

  def prepare_mail(release_log)
    @release_log = release_log

    @release_log_configuration = release_log.project.release_log_configuration
    @release_log_queue = @release_log_configuration.release_log_queue

    @last_release_log_notification = ReleaseLogNotification.for_queue_and_title(release_log).first if @release_log_queue.present?
    headers['In-Reply-To'] = "<#{@last_release_log_notification.message_id}>" if @last_release_log_notification.present?

    message_id release_log
    template = yield

    @release_log.attachments.each do |attachment|
      replacement = "src=\"#{download_named_attachment_path(attachment, attachment.filename)}\""

      if template.include? replacement
        attachments.inline[attachment.filename] = File.read(attachment.diskfile) unless attachments[attachment.filename].present?
        new_value = "src=\"#{attachments[attachment.filename].url}\""
        template.gsub!(replacement, new_value)
      end
    end

    mail(:to => @release_log_configuration.recipients,
         :subject => "#{release_log.title} - Release log") do |format|
      format.html {
        render :text => template
      }
    end
  end

  def release_log_publish_notification(release_log)
    prepare_mail(release_log) do
      render_to_string(:template => 'release_log_mailer/release_log_publish_notification')
    end
  end

  def release_log_rollback_notification(release_log)
    prepare_mail(release_log) do
      render_to_string(:template => 'release_log_mailer/release_log_rollback_notification')
    end
  end

  def release_log_cancel_notification(release_log)
    prepare_mail(release_log) do
      render_to_string(:template => 'release_log_mailer/release_log_cancel_notification')
    end
  end

  def release_log_successful_release_notification(release_log)
    prepare_mail(release_log) do
      render_to_string(:template => 'release_log_mailer/release_log_successful_release_notification')
    end
  end
end
