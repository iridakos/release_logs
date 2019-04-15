class ReleaseLog < ActiveRecord::Base
  include Redmine::I18n

  unloadable

  DRAFT_STATUS = 'draft'
  PUBLISHED_STATUS = 'published'
  RELEASED_STATUS = 'released'
  CANCELLED_STATUS = 'cancelled'
  ROLLED_BACK_STATUS = 'rolled_back'
  PENDING_RELEASE_STATUS = 'pending_release'

  has_many :release_log_entries, :dependent => :destroy, :inverse_of => :release_log, :validate => true
  has_many :release_log_notifications, :dependent => :destroy, :inverse_of => :release_log

  belongs_to :project, :inverse_of => :release_logs
  belongs_to :user
  belongs_to :publisher, :class_name => 'User', :foreign_key => 'published_by'
  belongs_to :canceller, :class_name => 'User', :foreign_key => 'cancelled_by'
  belongs_to :rollbacker, :class_name => 'User', :foreign_key => 'rolled_back_by'
  belongs_to :release_log_queue, :inverse_of => :release_logs

  accepts_nested_attributes_for :release_log_entries, :allow_destroy => true

  acts_as_attachable :view_permission => :view_project_release_logs,
                     :delete_permission => :manage_project_release_logs

  #before_save :assign_to_release_log_queue

  ### Scopes ###
  scope :for_project, lambda { |project| where(:project_id => project.id) }
  scope :latest, lambda { order('COALESCE(release_logs.released_at, release_logs.created_at) desc') }

  ### Query scopes ###
  scope :with_text, lambda { |text| joins(:release_log_entries => [ :issue ]).where('release_logs.title like :text or release_logs.description like :text or issues.subject like :text or issues.description like :text or release_log_entries.note like :text', :text => text) }
  scope :with_issue_text, lambda { |text| joins(:release_log_entries => [ :issue ]).where('issues.subject like :text or issues.description like :text', :text => text) }
  scope :with_release_log_title_text, lambda { |text| where('release_logs.title like :text', :text => text) }
  scope :with_release_log_description_text, lambda { |text| where('release_logs.description like :text', :text => text) }
  scope :with_release_log_entry_note_text, lambda { |text| joins(:release_log_entries).where('release_log_entries.note like :text', :text => text) }

  scope :with_draft_status, lambda { where(:published_at => nil) }
  scope :with_pending_release_status, lambda { where('published_at IS NOT NULL and released_at > :now and cancelled_at IS NULL and rolled_back_at IS NULL', :now => Time.now) }
  scope :with_released_status, lambda { where('published_at IS NOT NULL and released_at <= :now and cancelled_at IS NULL and rolled_back_at IS NULL', :now => Time.now) }
  scope :with_rolled_back_status, lambda { where('published_at IS NOT NULL and rolled_back_at IS NOT NULL', :now => Time.now) }
  scope :with_cancelled_status, lambda { where('published_at IS NOT NULL and cancelled_at IS NOT NULL', :now => Time.now) }

  scope :with_queue, lambda { |queue| where(:release_log_queue_id => queue) }

  scope :temporal, lambda { |type, from, to|
    column = case type
               when 'released' then
                 'released_at'
               when 'cancelled' then
                 'cancelled_at'
               when 'rolled_back' then
                 'rolled_back_at'
               else
                 raise "Unknown column '#{type}_at'"
             end

    script = ["#{column} IS NOT NULL"]
    params = { :column => column }
    if from.present?
      script << "#{column} >= :from"
      params[:from] = from
    end

    if to.present?
      script << "#{column} <= :to"
      params[:to] = to
    end

    where(script.join(' and '), params)
  }

  scope :with_project, lambda { |project, descendants = false|
    if descendants
      includes(:project).where('projects.id = :project_id or (projects.lft >= :lft and projects.rgt < :rgt)', :project_id => project.id, :lft => project.lft, :rgt => project.rgt)
    else
      joins(:project).where(:project_id => project.id)
    end
  }

  validates :title, :presence => true, :length => { :maximum => 255 }
  validates :released_at, :presence => { :unless => 'release_upon_publish' }
  validates :release_log_entries, :association_count => { :minimum => 1 }
  validates :rollback_reason, :presence => { :if => 'rolled_back_at.present?' }
  validates :cancellation_reason, :presence => { :if => 'cancelled_at.present?' }
  validate :release_log_queue_id
  validate :unique_issues

  def created_on
    self.released_at
  end

  def draft?
    published_at.blank?
  end

  def published?
    published_at.present?
  end

  def cancelled?
    cancelled_at.present?
  end

  def rolled_back?
    rolled_back_at.present?
  end

  def released?
    published? && released_at.present? && released_at <= Time.current && !cancelled? && !rolled_back?
  end

  def pending_release?
    published? && released_at.present? && !cancelled? && !rolled_back? && released_at >= Time.current
  end

  def status
    return DRAFT_STATUS if draft?
    return ROLLED_BACK_STATUS if rolled_back?
    return CANCELLED_STATUS if cancelled?
    return RELEASED_STATUS if released?
    return PENDING_RELEASE_STATUS if pending_release?
    PUBLISHED_STATUS
  end

  def queue_title_for_release_log
    date = release_upon_publish ? DateTime.now : (released_at.presence || DateTime.now)
    version = Version.find(version_id) if version_id?
    ReleaseLogQueue.find(release_log_queue_id).generate_title(project, date, version)
  end

  def publish(user)
    return if published?
    self.published_at = Time.now
    self.published_by = user.id
    self.released_by = user.id

    self.released_at = Time.current if self.release_upon_publish
  end

  protected

  # def assign_to_release_log_queue
  #   proj = self.project || Project.find(self.project_id)
  #   self.release_log_queue_id = proj.release_log_configuration.release_log_queue.id if proj.release_log_configuration.present? && proj.release_log_configuration.release_log_queue.present?
  # end

  def unique_issues
    issues = release_log_entries.select{ |entry| !entry.marked_for_destruction? }.map(&:issue_id).compact
    if issues && issues.size != issues.uniq.size
      errors.add(:base, :unique_issues)
    end
  end
end
