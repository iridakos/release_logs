class ReleaseLogQueue < ActiveRecord::Base
  include Redmine::I18n

  unloadable

  DATE_INTERPOLATIONS = {
      :year => lambda { |date| date.strftime('%Y') },
      :year_short => lambda { |date| date.strftime('%y') },
      :month => lambda { |date| date.strftime('%m') },
      :month_short_name => lambda { |date| date.strftime('%b') },
      :month_name => lambda { |date| date.strftime('%B') },
      :day => lambda { |date| date.strftime('%d') },
      :day_short_name => lambda { |date| date.strftime('%a') },
      :day_name => lambda { |date| date.strftime('%A') },
      :week => lambda { |date| date.strftime('%W').rjust(2, '0') }
  }.freeze

  PROJECT_INTERPOLATIONS = {
      :project_name => lambda { |project| project.name }
  }.freeze

  has_many :release_log_entry_categories, :dependent => :destroy, :inverse_of => :release_log_queue
  has_many :release_log_notifications, :dependent => :nullify, :inverse_of => :release_log_queue
  has_many :release_logs, :dependent => :nullify, :inverse_of => :release_log_queue

  accepts_nested_attributes_for :release_log_entry_categories, :allow_destroy => true

  validates :release_log_entry_categories, :association_count => { :minimum => 1, :unless => 'group_by_issue_type' }

  validates :name,
            :presence => true,
            :length => { :maximum => 255 },
            :uniqueness => true

  validates :title_template, :presence => true, :length => { :maximum => 255 }

  validates :email_notification_recipients, :presence => true, :multiple_email_addresses => true

  validate :title_template_syntax

  def generate_title(project = Project.new(:name => 'TestProject'), date = Date.today)
    return nil unless title_template.present?

    title = DATE_INTERPOLATIONS.to_a.inject(title_template) do |title, interpolation|
      title.gsub("{{#{interpolation[0]}}}", interpolation[1].call(date))
    end

    PROJECT_INTERPOLATIONS.to_a.inject(title) do |title, interpolation|
      title.gsub("{{#{interpolation[0]}}}", interpolation[1].call(project))
    end
  end

  def recipient_addresses
    self.email_notification_recipients.split(',')
  end

  protected

  def title_template_syntax
    generate_title
  rescue
    errors.add(:title_template, :invalid)
  end
end
