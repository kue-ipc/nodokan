class Confirmation < ApplicationRecord
  include Bitwise
  include Duration

  has_paper_trail

  belongs_to :node
  belongs_to :security_software, optional: true

  NUM_ATTRS = %w[existence content os_update app_update software
    security_update security_scan].freeze

  ALL_ATTRS = (NUM_ATTRS + %w[security_hardware security_software]).freeze

  bitwise :security_hardware, {
    encrypted: 0x1,
    zero_client: 0x2,
    remote_wipe: 0x4,
    no_storage: 0x8,
    wired: 0x10,
    locked_locker: 0x20,
    safety_area: 0x40,
    none: 0,
    unknown: -1,
  }, prefix: true

  enum :existence, {
    existing: 0,
    abandoned: 16,
    unnecessary: 19,
    missing: 17,
    not_my_own: 18,
    unknown: -1,
  }, prefix: true, validate: true

  enum :content, {
    correct: 0,
    incorrect: 16,
    unknown: -1,
  }, prefix: true, validate: true

  enum :os_update, {
    auto: 0,
    manual: 1,
    updated: 2,
    secured: 3,
    unnecessary: 8,
    not_do: 16,
    eol: 17,
    unknown: -1,
  }, prefix: true, validate: true

  enum :app_update, {
    auto: 0,
    manual: 1,
    updated: 2,
    secured: 3,
    unnecessary: 8,
    not_implemented: 9,
    not_do: 16,
    eol: 17,
    unknown: -1,
  }, prefix: true, validate: true

  enum :software, {
    trusted: 0,
    os_only: 9,
    untrusted: 16,
    unknown: -1,
  }, prefix: true, validate: true

  enum :security_update, {
    auto: 0,
    built_in: 4,
    not_implemented: 9,
    not_do: 16,
    eol: 17,
    unknown: -1,
  }, prefix: true, validate: true

  enum :security_scan, {
    auto: 0,
    manual: 1,
    not_implemented: 9,
    not_do: 16,
    unknown: -1,
  }, prefix: true, validate: true

  validates :existence, presence: true
  validates :content, presence: true
  validates :os_update, presence: true
  validates :app_update, presence: true
  validates :software, presence: true
  validates :security_hardware, presence: true
  validates :security_update, presence: true
  validates :security_scan, presence: true

  def check(num)
    if num.nil? || num.negative?
      :unknown
    elsif num < 16
      :ok
    else
      :problem
    end
  end

  NUM_ATTRS.each do |name|
    define_method("check_#{name}") do
      check(Confirmation.__send__(name.pluralize)[__send__(name)])
    end

    define_method("#{name}_ok?") do
      __send__("check_#{name}") == :ok
    end

    define_method("#{name}_problem?") do
      __send__("check_#{name}") == :problem
    end
  end

  def security_hardware_ok?
    security_hardware&.positive?
  end

  def security_software_ok?
    security_software&.approved
  end

  def security_hardware_problem?
    security_hardware&.zero?
  end

  def security_software_problem?
    !security_software.nil? &&
      !security_software.installation_method.nil? &&
      !security_software.installation_method_unknown? &&
      !security_software.approved
  end

  def security_hardware_unknown?
    security_hardware.nil? || security_hardware.negative?
  end

  def security_software_unknown?
    security_software.nil? ||
      security_software&.installation_method.nil? ||
      security_software&.installation_method_unknown?
  end

  def exist?
    existence_existing?
  end

  def ok?
    if node.logical?
      ["existence", "content"].all? { |name| __send__("#{name}_ok?") }
    else
      ALL_ATTRS.all? { |name| __send__("#{name}_ok?") }
    end
  end

  alias approvable? ok?

  def problem?
    ALL_ATTRS.any? { |name| __send__("#{name}_problem?") }
  end

  def unknown?
    ALL_ATTRS.any? { |name| self[name] == "unknown" }
  end

  def validity_period
    if approved
      duration(Settings.config.confirmation_period.approved)
    else
      duration(Settings.config.confirmation_period.unapproved)
    end
  end

  def expire_soon_period
    duration(Settings.config.confirmation_period.expire_soon)
  end

  def expiration
    validity_period.after(confirmed_at)
  end

  def status(time = Time.current)
    if confirmed_at.blank?
      :unconfirmed
    elsif expiration <= time
      :expired
    elsif !approved
      :unapproved
    elsif expiration <= expire_soon_period.after(time)
      :expire_soon
    else
      :approved
    end
  end

  def status_duration(time = Time.current)
    start_time = case status(time)
    in :approved | :unapproved
      confirmed_at
    in :expire_soon
      expire_soon_period.before(expiration)
    in :expired
      expiration
    in :unconfirmed
      node.created_at
    end
    time - start_time
  end

  def destroyable?
    existence_abandoned? ||
      existence_unnecessary? ||
      existence_missing? ||
      existence_unknown?
  end

  def transferable?
    existence_not_my_own?
  end

  def check_and_approve!(time = Time.current)
    if !exist?
      self.content = :unknown
      self.os_update = :unknown
      self.app_update = :unknown
      self.software = :unknown
      self.security_hardware = Confirmation.security_hardwares[:unknown]
      self.security_software = nil
      self.security_update = :unknown
      self.security_scan = :unknown
    elsif node.logical?
      self.os_update = :unknown
      self.app_update = :unknown
      self.security_hardware = Confirmation.security_hardwares[:unknown]
      self.security_software = nil
      self.security_update = :unknown
      self.security_scan = :unknown
    elsif security_software.nil?
      self.security_update = :unknown
      self.security_scan = :unknown
    end

    self.approved = approvable?

    self.confirmed_at = time
  end
end
