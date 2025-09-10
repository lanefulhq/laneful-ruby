# frozen_string_literal: true

module Laneful
  # Represents an email address with an optional name
  class Address
    attr_reader :email, :name

    def initialize(email, name = nil)
      @email = email
      @name = name
      validate!
    end

    # Creates an Address from a hash representation
    def self.from_hash(data)
      new(data['email'], data['name'])
    end

    def to_hash
      hash = { 'email' => email }
      hash['name'] = name if name && !name.empty?
      hash
    end

    def ==(other)
      return false unless other.is_a?(Address)

      email == other.email && name == other.name
    end

    def eql?(other)
      self == other
    end

    def hash
      [email, name].hash
    end

    def to_s
      if name && !name.strip.empty?
        "#{name} <#{email}>"
      else
        email
      end
    end

    private

    def validate!
      raise ValidationException, 'Email address cannot be empty' if email.nil? || email.strip.empty?

      # Basic email validation
      email_regex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
      return if email.match?(email_regex)

      raise ValidationException, "Invalid email address format: #{email}"
    end
  end

  # Configuration for email tracking settings
  class TrackingSettings
    attr_reader :opens, :clicks, :unsubscribes

    def initialize(opens: false, clicks: false, unsubscribes: false)
      @opens = opens
      @clicks = clicks
      @unsubscribes = unsubscribes
    end

    # Creates tracking settings from a hash representation
    def self.from_hash(data)
      new(
        opens: data['opens'] || false,
        clicks: data['clicks'] || false,
        unsubscribes: data['unsubscribes'] || false
      )
    end

    def to_hash
      {
        'opens' => opens,
        'clicks' => clicks,
        'unsubscribes' => unsubscribes
      }
    end

    def ==(other)
      return false unless other.is_a?(TrackingSettings)

      opens == other.opens && clicks == other.clicks && unsubscribes == other.unsubscribes
    end

    def eql?(other)
      self == other
    end

    def hash
      [opens, clicks, unsubscribes].hash
    end

    def to_s
      "TrackingSettings{opens=#{opens}, clicks=#{clicks}, unsubscribes=#{unsubscribes}}"
    end
  end

  # Represents a file attachment for an email
  class Attachment
    attr_reader :filename, :content_type, :content

    def initialize(filename, content_type, content)
      @filename = filename
      @content_type = content_type
      @content = content
      validate!
    end

    # Creates an attachment from a file
    def self.from_file(file_path)
      filename = File.basename(file_path)
      content_type = detect_content_type(file_path)
      content = Base64.strict_encode64(File.binread(file_path))
      new(filename, content_type, content)
    end

    # Creates an attachment from a hash representation
    def self.from_hash(data)
      filename = data['file_name'] || data['filename']  # Support both field names
      new(filename, data['content_type'], data['content'])
    end

    def to_hash
      {
        'file_name' => filename,
        'content_type' => content_type,
        'content' => content
      }
    end

    def ==(other)
      return false unless other.is_a?(Attachment)

      filename == other.filename && content_type == other.content_type && content == other.content
    end

    def eql?(other)
      self == other
    end

    def hash
      [filename, content_type, content].hash
    end

    def to_s
      "Attachment{filename='#{filename}', contentType='#{content_type}', contentLength=#{content&.length || 0}}"
    end

    def self.detect_content_type(file_path)
      # Simple content type detection based on file extension
      case File.extname(file_path).downcase
      when '.pdf'
        'application/pdf'
      when '.jpg', '.jpeg'
        'image/jpeg'
      when '.png'
        'image/png'
      when '.gif'
        'image/gif'
      when '.txt'
        'text/plain'
      when '.html', '.htm'
        'text/html'
      when '.doc'
        'application/msword'
      when '.docx'
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      when '.xls'
        'application/vnd.ms-excel'
      when '.xlsx'
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      else
        'application/octet-stream'
      end
    end

    private

    def validate!
      raise ValidationException, 'Filename cannot be empty' if filename.nil? || filename.strip.empty?
      raise ValidationException, 'Content type cannot be empty' if content_type.nil? || content_type.strip.empty?
      raise ValidationException, 'Content cannot be empty' if content.nil? || content.strip.empty?
    end
  end

  # Represents a single email to be sent
  class Email
    attr_reader :from, :to, :cc, :bcc, :subject, :text_content, :html_content,
                :template_id, :template_data, :attachments, :headers, :reply_to,
                :send_time, :webhook_data, :tag, :tracking

    def initialize(builder)
      @from = builder.instance_variable_get(:@from)
      @to = builder.instance_variable_get(:@to).dup.freeze
      @cc = builder.instance_variable_get(:@cc).dup.freeze
      @bcc = builder.instance_variable_get(:@bcc).dup.freeze
      @subject = builder.instance_variable_get(:@subject)
      @text_content = builder.instance_variable_get(:@text_content)
      @html_content = builder.instance_variable_get(:@html_content)
      @template_id = builder.instance_variable_get(:@template_id)
      @template_data = builder.instance_variable_get(:@template_data)&.dup&.freeze
      @attachments = builder.instance_variable_get(:@attachments).dup.freeze
      @headers = builder.instance_variable_get(:@headers)&.dup&.freeze
      @reply_to = builder.instance_variable_get(:@reply_to)
      @send_time = builder.instance_variable_get(:@send_time)
      @webhook_data = builder.instance_variable_get(:@webhook_data)&.dup&.freeze
      @tag = builder.instance_variable_get(:@tag)
      @tracking = builder.instance_variable_get(:@tracking)
      validate!
    end

    # Creates an Email from a hash representation
    def self.from_hash(data)
      builder = Builder.new

      builder.from(Address.from_hash(data['from'])) if data && data['from']

      data['to'].each { |to_data| builder.to(Address.from_hash(to_data)) } if data && data['to']

      data['cc'].each { |cc_data| builder.cc(Address.from_hash(cc_data)) } if data && data['cc']

      data['bcc'].each { |bcc_data| builder.bcc(Address.from_hash(bcc_data)) } if data && data['bcc']

      builder.subject(data['subject']) if data && data['subject']
      builder.text_content(data['text_content']) if data && data['text_content']
      builder.html_content(data['html_content']) if data && data['html_content']
      builder.template_id(data['template_id']) if data && data['template_id']
      builder.template_data(data['template_data']) if data && data['template_data']
      builder.headers(data['headers']) if data && data['headers']
      builder.reply_to(Address.from_hash(data['reply_to'])) if data && data['reply_to']
      builder.send_time(data['send_time']) if data && data['send_time']
      builder.webhook_data(data['webhook_data']) if data && data['webhook_data']
      builder.tag(data['tag']) if data && data['tag']
      builder.tracking(TrackingSettings.from_hash(data['tracking'])) if data && data['tracking']

      if data && data['attachments']
        data['attachments'].each { |attachment_data| builder.attachment(Attachment.from_hash(attachment_data)) }
      end

      builder.build
    end

    def to_hash
      hash = {}

      # Required fields
      hash['from'] = from.to_hash
      hash['to'] = to.map(&:to_hash)
      hash['subject'] = subject if subject

      # Optional fields (only include if not nil/empty)
      hash['cc'] = cc.map(&:to_hash) unless cc.empty?
      hash['bcc'] = bcc.map(&:to_hash) unless bcc.empty?
      hash['text_content'] = text_content if text_content && !text_content.strip.empty?
      hash['html_content'] = html_content if html_content && !html_content.strip.empty?
      hash['template_id'] = template_id if template_id && !template_id.strip.empty?
      hash['template_data'] = template_data if template_data
      hash['attachments'] = attachments.map(&:to_hash) unless attachments.empty?
      hash['headers'] = headers if headers
      hash['reply_to'] = reply_to.to_hash if reply_to
      hash['send_time'] = send_time if send_time
      hash['webhook_data'] = webhook_data if webhook_data
      hash['tag'] = tag if tag && !tag.strip.empty?
      hash['tracking'] = tracking.to_hash if tracking

      hash
    end

    def ==(other)
      return false unless other.is_a?(Email)

      from == other.from &&
        to == other.to &&
        cc == other.cc &&
        bcc == other.bcc &&
        subject == other.subject &&
        text_content == other.text_content &&
        html_content == other.html_content &&
        template_id == other.template_id &&
        template_data == other.template_data &&
        attachments == other.attachments &&
        headers == other.headers &&
        reply_to == other.reply_to &&
        send_time == other.send_time &&
        webhook_data == other.webhook_data &&
        tag == other.tag &&
        tracking == other.tracking
    end

    def eql?(other)
      self == other
    end

    def hash
      [from, to, cc, bcc, subject, text_content, html_content, template_id,
       template_data, attachments, headers, reply_to, send_time, webhook_data, tag, tracking].hash
    end

    def to_s
      has_text = text_content && !text_content.empty?
      has_html = html_content && !html_content.empty?

      <<~STR
        Email{
          from=#{from},
          to=#{to},
          subject='#{subject}',
          hasTextContent=#{has_text},
          hasHtmlContent=#{has_html},
          templateId='#{template_id}',
          attachments=#{attachments.size}
        }
      STR
    end

    private

    def validate!
      raise ValidationException, 'From address is required' if from.nil?

      # Must have at least one recipient
      if to.empty? && cc.empty? && bcc.empty?
        raise ValidationException, 'Email must have at least one recipient (to, cc, or bcc)'
      end

      # Must have either content or template
      has_content = (text_content && !text_content.strip.empty?) ||
                    (html_content && !html_content.strip.empty?)
      has_template = template_id && !template_id.strip.empty?

      unless has_content || has_template
        raise ValidationException, 'Email must have either content (text/HTML) or a template ID'
      end

      # Validate send time
      return unless send_time && send_time <= Time.now.to_i

      raise ValidationException, 'Send time must be in the future'
    end

    # Builder class for creating Email instances
    class Builder
      def initialize
        @to = []
        @cc = []
        @bcc = []
        @attachments = []
      end

      def from(address)
        @from = address
        self
      end

      def to(address)
        @to << address
        self
      end

      def cc(address)
        @cc << address
        self
      end

      def bcc(address)
        @bcc << address
        self
      end

      def subject(subject)
        @subject = subject
        self
      end

      def text_content(content)
        @text_content = content
        self
      end

      def html_content(content)
        @html_content = content
        self
      end

      def template_id(id)
        @template_id = id
        self
      end

      def template_data(data)
        @template_data = data
        self
      end

      def attachment(attachment)
        @attachments << attachment
        self
      end

      def headers(headers)
        @headers = headers
        self
      end

      def reply_to(address)
        @reply_to = address
        self
      end

      def send_time(time)
        @send_time = time
        self
      end

      def webhook_data(data)
        @webhook_data = data
        self
      end

      def tag(tag)
        @tag = tag
        self
      end

      def tracking(tracking)
        @tracking = tracking
        self
      end

      def build
        Email.new(self)
      end
    end
  end
end
