# frozen_string_literal: true

module Laneful
  # An unsubscribe group in a workspace
  class UnsubscribeGroup
    attr_reader :unsubscribe_group_id, :name, :created_at

    def initialize(unsubscribe_group_id:, name:, created_at: 0)
      @unsubscribe_group_id = unsubscribe_group_id
      @name = name
      @created_at = created_at
    end

    def self.from_hash(data)
      new(
        unsubscribe_group_id: (data['unsubscribe_group_id'] || 0).to_i,
        name: data['name'] || '',
        created_at: (data['created_at'] || 0).to_i
      )
    end

    def to_hash
      {
        'unsubscribe_group_id' => unsubscribe_group_id,
        'name' => name,
        'created_at' => created_at
      }
    end
  end

  # Paginated list of unsubscribe groups
  class ListUnsubscribeGroupsResponse
    attr_reader :unsubscribe_groups, :next_cursor

    def initialize(unsubscribe_groups:, next_cursor: nil)
      @unsubscribe_groups = unsubscribe_groups || []
      @next_cursor = next_cursor
    end

    def self.from_hash(data)
      groups = (data['unsubscribe_groups'] || []).map { |group| UnsubscribeGroup.from_hash(group) }
      new(unsubscribe_groups: groups, next_cursor: data['next_cursor'])
    end
  end

  # Query parameters for listing unsubscribe groups
  class ListUnsubscribeGroupsParams
    attr_reader :cursor, :limit, :search

    def initialize(cursor: nil, limit: nil, search: nil)
      @cursor = cursor
      @limit = limit
      @search = search
    end

    def to_query
      query = {}
      query['cursor'] = cursor if present?(cursor)
      query['limit'] = limit if limit&.positive?
      query['search'] = search if present?(search)
      query
    end

    private

    def present?(value)
      !value.nil? && !value.to_s.empty?
    end
  end

  # A sending domain and its verification state
  class Domain
    attr_reader :domain, :tracking, :return_path, :verified, :tracking_verified,
                :return_path_verified, :dkim1_verified, :dkim2_verified,
                :dmarc_verified, :require_tls, :email_track_id

    def initialize(domain:, tracking: '', return_path: '', verified: false, tracking_verified: false,
                   return_path_verified: false, dkim1_verified: false, dkim2_verified: false,
                   dmarc_verified: false, require_tls: false, email_track_id: '')
      @domain = domain
      @tracking = tracking
      @return_path = return_path
      @verified = verified
      @tracking_verified = tracking_verified
      @return_path_verified = return_path_verified
      @dkim1_verified = dkim1_verified
      @dkim2_verified = dkim2_verified
      @dmarc_verified = dmarc_verified
      @require_tls = require_tls
      @email_track_id = email_track_id
    end

    def self.from_hash(data)
      new(
        domain: data['domain'] || '',
        tracking: data['tracking'] || '',
        return_path: data['return_path'] || '',
        verified: truthy?(data['verified']),
        tracking_verified: truthy?(data['tracking_verified']),
        return_path_verified: truthy?(data['return_path_verified']),
        dkim1_verified: truthy?(data['dkim1_verified']),
        dkim2_verified: truthy?(data['dkim2_verified']),
        dmarc_verified: truthy?(data['dmarc_verified']),
        require_tls: truthy?(data['require_tls']),
        email_track_id: data['email_track_id'] || ''
      )
    end

    def to_hash
      {
        'domain' => domain,
        'tracking' => tracking,
        'return_path' => return_path,
        'verified' => verified,
        'tracking_verified' => tracking_verified,
        'return_path_verified' => return_path_verified,
        'dkim1_verified' => dkim1_verified,
        'dkim2_verified' => dkim2_verified,
        'dmarc_verified' => dmarc_verified,
        'require_tls' => require_tls,
        'email_track_id' => email_track_id
      }
    end

    def self.truthy?(value)
      value == true
    end
  end

  # Paginated list of sending domains
  class ListDomainsResponse
    attr_reader :domains, :next_cursor

    def initialize(domains:, next_cursor: nil)
      @domains = domains || []
      @next_cursor = next_cursor
    end

    def self.from_hash(data)
      pagination = data['pagination'] || {}
      new(
        domains: (data['domains'] || []).map { |domain| Domain.from_hash(domain) },
        next_cursor: pagination['next_cursor']
      )
    end
  end

  # Query parameters for listing domains
  class ListDomainsParams
    attr_reader :cursor, :limit, :filter_domain

    def initialize(cursor: nil, limit: nil, filter_domain: nil)
      @cursor = cursor
      @limit = limit
      @filter_domain = filter_domain
    end

    def to_query
      query = {}
      query['cursor'] = cursor if present?(cursor)
      query['limit'] = limit if limit&.positive?
      query['filter[domain]'] = filter_domain if present?(filter_domain)
      query
    end

    private

    def present?(value)
      !value.nil? && !value.to_s.empty?
    end
  end

  # Request body for creating a sending domain
  class CreateDomainRequest
    attr_reader :domain, :tracking, :return_path, :require_tls, :email_track_id

    def initialize(domain:, tracking:, return_path:, require_tls: nil, email_track_id: nil)
      @domain = domain
      @tracking = tracking
      @return_path = return_path
      @require_tls = require_tls
      @email_track_id = email_track_id
    end

    def to_hash
      hash = {
        'domain' => domain,
        'tracking' => tracking,
        'return_path' => return_path
      }
      hash['require_tls'] = require_tls unless require_tls.nil?
      hash['email_track_id'] = email_track_id if email_track_id && !email_track_id.empty?
      hash
    end
  end

  # Request body for updating a domain's mutable settings.
  # Pass a track ID to set the email track, an empty string to clear it,
  # or nil to leave it unchanged.
  class UpdateDomainRequest
    attr_reader :email_track_id

    def initialize(email_track_id = nil)
      @email_track_id = email_track_id
    end

    def to_hash
      return {} if email_track_id.nil?

      { 'email_track_id' => email_track_id }
    end
  end

  # Generic success message from mutating endpoints
  class SuccessResponse
    attr_reader :message

    def initialize(message:)
      @message = message
    end

    def self.from_hash(data)
      new(message: data['message'] || '')
    end

    def to_hash
      { 'message' => message }
    end
  end

  # A sending domain whose spam complaint ratio reached a critical level
  class DomainSpamRatioRadar
    attr_reader :workspace_id, :domain, :esp, :spam_ratio, :date

    def initialize(workspace_id:, domain:, esp:, spam_ratio:, date:)
      @workspace_id = workspace_id
      @domain = domain
      @esp = esp
      @spam_ratio = spam_ratio
      @date = date
    end

    def self.from_hash(data)
      new(
        workspace_id: (data['workspace_id'] || 0).to_i,
        domain: data['domain'] || '',
        esp: data['esp'] || '',
        spam_ratio: (data['spam_ratio'] || 0).to_f,
        date: (data['date'] || '').to_s
      )
    end
  end

  # Paginated list of domain spam-ratio radar entries
  class ListDomainSpamRatioRadarResponse
    attr_reader :radar, :next_cursor

    def initialize(radar:, next_cursor: nil)
      @radar = radar || []
      @next_cursor = next_cursor
    end

    def self.from_hash(data)
      new(
        radar: (data['radar'] || []).map { |entry| DomainSpamRatioRadar.from_hash(entry) },
        next_cursor: data['next_cursor']
      )
    end
  end

  # Query parameters for listing domain spam-ratio radar entries
  class ListDomainSpamRatioRadarParams
    attr_reader :workspace_ids, :domain, :start_date, :end_date, :cursor, :limit

    def initialize(workspace_ids: [], domain: nil, start_date: nil, end_date: nil, cursor: nil, limit: nil)
      @workspace_ids = workspace_ids || []
      @domain = domain
      @start_date = start_date
      @end_date = end_date
      @cursor = cursor
      @limit = limit
    end

    def to_query
      query = {}
      query['workspace_ids'] = workspace_ids unless workspace_ids.empty?
      query['domain'] = domain if present?(domain)
      query['start_date'] = start_date if present?(start_date)
      query['end_date'] = end_date if present?(end_date)
      query['cursor'] = cursor if present?(cursor)
      query['limit'] = limit if limit&.positive?
      query
    end

    private

    def present?(value)
      !value.nil? && !value.to_s.empty?
    end
  end

  # A daily Gmail spam-rate report from Google Postmaster Tools
  class GooglePostmasterSpamReport
    attr_reader :workspace_id, :domain, :date, :spam_ratio

    def initialize(workspace_id:, domain:, date:, spam_ratio:)
      @workspace_id = workspace_id
      @domain = domain
      @date = date
      @spam_ratio = spam_ratio
    end

    def self.from_hash(data)
      new(
        workspace_id: (data['workspace_id'] || 0).to_i,
        domain: data['domain'] || '',
        date: (data['date'] || '').to_s,
        spam_ratio: (data['spam_ratio'] || 0).to_f
      )
    end
  end

  # Paginated list of Google Postmaster spam reports
  class ListGooglePostmasterSpamReportsResponse
    attr_reader :spam_reports, :next_cursor

    def initialize(spam_reports:, next_cursor: nil)
      @spam_reports = spam_reports || []
      @next_cursor = next_cursor
    end

    def self.from_hash(data)
      new(
        spam_reports: (data['spam_reports'] || []).map { |report| GooglePostmasterSpamReport.from_hash(report) },
        next_cursor: data['next_cursor']
      )
    end
  end

  # Query parameters for listing Google Postmaster spam reports
  class ListGooglePostmasterSpamReportsParams
    attr_reader :workspace_ids, :domain, :start_date, :end_date, :cursor, :limit

    def initialize(workspace_ids: [], domain: nil, start_date: nil, end_date: nil, cursor: nil, limit: nil)
      @workspace_ids = workspace_ids || []
      @domain = domain
      @start_date = start_date
      @end_date = end_date
      @cursor = cursor
      @limit = limit
    end

    def to_query
      query = {}
      query['workspace_ids'] = workspace_ids unless workspace_ids.empty?
      query['domain'] = domain if present?(domain)
      query['start_date'] = start_date if present?(start_date)
      query['end_date'] = end_date if present?(end_date)
      query['cursor'] = cursor if present?(cursor)
      query['limit'] = limit if limit&.positive?
      query
    end

    private

    def present?(value)
      !value.nil? && !value.to_s.empty?
    end
  end

  # A daily Microsoft SNDS report for a sending IP
  class SndsReport
    FILTER_UNKNOWN = ''
    FILTER_GREEN = 'GREEN'
    FILTER_YELLOW = 'YELLOW'
    FILTER_RED = 'RED'

    attr_reader :ip, :date, :rcpt_commands, :data_commands, :message_recipients,
                :filter_result, :complaint_rate, :trap_hits

    def initialize(ip:, date:, rcpt_commands:, data_commands:, message_recipients:,
                   filter_result:, complaint_rate:, trap_hits:)
      @ip = ip
      @date = date
      @rcpt_commands = rcpt_commands
      @data_commands = data_commands
      @message_recipients = message_recipients
      @filter_result = filter_result
      @complaint_rate = complaint_rate
      @trap_hits = trap_hits
    end

    def self.from_hash(data)
      new(
        ip: data['ip'] || '',
        date: (data['date'] || '').to_s,
        rcpt_commands: (data['rcpt_commands'] || 0).to_i,
        data_commands: (data['data_commands'] || 0).to_i,
        message_recipients: (data['message_recipients'] || 0).to_i,
        filter_result: data['filter_result'] || FILTER_UNKNOWN,
        complaint_rate: (data['complaint_rate'] || 0).to_f,
        trap_hits: (data['trap_hits'] || 0).to_i
      )
    end
  end

  # Paginated list of Microsoft SNDS reports
  class ListSndsReportsResponse
    attr_reader :snds_reports, :next_cursor

    def initialize(snds_reports:, next_cursor: nil)
      @snds_reports = snds_reports || []
      @next_cursor = next_cursor
    end

    def self.from_hash(data)
      new(
        snds_reports: (data['snds_reports'] || []).map { |report| SndsReport.from_hash(report) },
        next_cursor: data['next_cursor']
      )
    end
  end

  # Query parameters for listing Microsoft SNDS reports
  class ListSndsReportsParams
    attr_reader :ip, :start_date, :end_date, :cursor, :limit

    def initialize(ip: nil, start_date: nil, end_date: nil, cursor: nil, limit: nil)
      @ip = ip
      @start_date = start_date
      @end_date = end_date
      @cursor = cursor
      @limit = limit
    end

    def to_query
      query = {}
      query['ip'] = ip if present?(ip)
      query['start_date'] = start_date if present?(start_date)
      query['end_date'] = end_date if present?(end_date)
      query['cursor'] = cursor if present?(cursor)
      query['limit'] = limit if limit&.positive?
      query
    end

    private

    def present?(value)
      !value.nil? && !value.to_s.empty?
    end
  end
end
