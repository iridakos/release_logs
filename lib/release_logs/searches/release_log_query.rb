module ReleaseLogs
  module Searches
    class ReleaseLogQuery
      include ActiveModel::Validations
      include Redmine::I18n

      def initialize(h)
        h.each { |k,v| send("#{k}=",v) }
      end

      QUERY_TERM_SCOPES = [ 'query_term_in_issue',
                            'query_term_release_log_title',
                            'query_term_in_release_log_description',
                            'query_term_in_release_log_notes' ]

      RELEASE_LOG_STATUSES = [ReleaseLog::DRAFT_STATUS,
                              ReleaseLog::PENDING_RELEASE_STATUS,
                              ReleaseLog::RELEASED_STATUS,
                              ReleaseLog::CANCELLED_STATUS,
                              ReleaseLog::ROLLED_BACK_STATUS]

      TEMPORAL_TYPES = ['released', 'rolled_back', 'cancelled']

      # The query text
      attr_accessor :query_term

      # Flags where to search the query text in
      attr_accessor :query_term_scope

      # The release log status
      attr_accessor :release_log_status

      # Temporal
      attr_accessor :temporal_type
      attr_accessor :temporal_from
      attr_accessor :temporal_to

      # Projects
      attr_accessor :query_project
      attr_accessor :query_project_and_subprojects

      validates :query_term_scope,
                :inclusion => QUERY_TERM_SCOPES,
                :allow_blank => true

      validates :temporal_type,
                :inclusion => TEMPORAL_TYPES,
                :allow_blank => true

      validates :release_log_status,
                :inclusion => RELEASE_LOG_STATUSES,
                :allow_blank => true

      validates :query_project, :presence => { :if => 'query_project_and_subprojects == "true"' }

      validates :temporal_type, :presence => { :if => 'temporal_to.present? || temporal_from.present?'}

      validates :temporal_from, :presence => { :if => 'temporal_type.present? && !temporal_to.present?'}

      validates :temporal_to, :presence => { :if => 'temporal_type.present? && !temporal_from.present?'}

      def to_key
      end

      def execute(offset = nil, limit = nil)
        return [] unless self.valid?

        scope = ReleaseLog
        term = query_term.present? ? "%#{query_term}%" : nil

        if term.present?
          case query_term_scope
            when nil, ''
              scope = scope.send(:with_text, term)
            when 'query_term_in_issue'
              scope = scope.send(:with_issue_text, term)
            when 'query_term_release_log_title'
              scope = scope.send(:with_release_log_title_text, term)
            when 'query_term_in_release_log_description'
              scope = scope.send(:with_release_log_description_text, term)
            when 'query_term_in_release_log_notes'
              scope = scope.send(:with_release_log_entry_note_text, term)
          end
        end

        case release_log_status.presence
          when ReleaseLog::DRAFT_STATUS
            scope = scope.send(:with_draft_status)
          when ReleaseLog::RELEASED_STATUS
            scope = scope.send(:with_released_status)
          when ReleaseLog::CANCELLED_STATUS
            scope = scope.send(:with_cancelled_status)
          when ReleaseLog::ROLLED_BACK_STATUS
            scope = scope.send(:with_rolled_back_status)
          when ReleaseLog::PENDING_RELEASE_STATUS
            scope = scope.send(:with_pending_release_status)
        end

        if temporal_type.present?
          scope = scope.send(:temporal, temporal_type, temporal_from, temporal_to)
        end

        if query_project.present?
          project = Project.find(query_project)
          and_subs = query_project_and_subprojects == 'true' ? true : false
          scope = scope.send(:with_project, project, and_subs)
        end

        if offset.present? && limit.present?
          scope = scope.latest.offset(offset).limit(limit)
        end

        scope
      end
    end
  end
end
