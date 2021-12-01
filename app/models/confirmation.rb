class Confirmation < ApplicationRecord
  belongs_to :node
  belongs_to :security_software, optional: true

  enum existence: {
    existing: 0,
    abandoned: 16,
    unnecessary: 19,
    missing: 17,
    not_my_own: 18,
    unknown: -1,
  }, _prefix: true

  enum content: {
    correct: 0,
    incorrect: 16,
    unknown: -1,
  }, _prefix: true

  enum os_update: {
    auto: 0,
    manual: 1,
    # updated: 2,
    secured: 3,
    unnecessary: 8,
    not_do: 16,
    eol: 17,
    unknown: -1,
  }, _prefix: true

  enum app_update: {
    auto: 0,
    manual: 1,
    # updated: 2,
    secured: 3,
    unnecessary: 8,
    not_implemented: 9,
    not_do: 16,
    eol: 17,
    unknown: -1,
  }, _prefix: true

  enum security_update: {
    auto: 0,
    built_in: 4,
    not_implemented: 9,
    not_do: 16,
    eol: 17,
    unknown: -1,
  }, _prefix: true

  enum security_scan: {
    auto: 0,
    manual: 1,
    not_implemented: 9,
    not_do: 16,
    unknown: -1,
  }, _prefix: true

  validates :existence, presence: true
  validates :content, presence: true
  validates :os_update, presence: true
  validates :app_update, presence: true
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

  def check_existence
    check(Confirmation.existences[existence])
  end

  def check_content
    check(Confirmation.contents[content])
  end

  def check_os_update
    check(Confirmation.os_updates[os_update])
  end

  def check_app_update
    check(Confirmation.app_updates[app_update])
  end

  def check_security_update
    check(Confirmation.security_updates[security_update])
  end

  def check_security_scan
    check(Confirmation.security_scans[security_scan])
  end

  def existence_ok?
    check_existence == :ok
  end

  def content_ok?
    check_content == :ok
  end

  def os_update_ok?
    check_os_update == :ok
  end

  def app_update_ok?
    check_app_update == :ok
  end

  def security_update_ok?
    check_security_update == :ok
  end

  def security_scan_ok?
    check_security_scan == :ok
  end

  def security_software_ok?
    security_software&.approved
  end

  def existence_problem?
    check_existence == :problem
  end

  def content_problem?
    check_content == :problem
  end

  def os_update_problem?
    check_os_update == :problem
  end

  def app_update_problem?
    check_app_update == :problem
  end

  def security_update_problem?
    check_security_update == :problem

  end

  def security_scan_problem?
    check_security_scan == :problem
  end

  def security_software_problem?
    !security_software.nil? &&
      !security_software.installation_method.nil? &&
      !security_software.installation_method_unknown? &&
      !security_software.approved
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
    if node.physical?
      %w[
        existence
        content
        os_update
        app_update
        security_update
        security_scan
        security_software
      ].all? { |name| __send__("#{name}_ok?") }
    else
      %w[
        existence
        content
      ].all? { |name| __send__("#{name}_ok?") }
    end
  end

  alias approvable? ok?

  def problem?
    %w[
      existence
      content
      os_update
      app_update
      security_update
      security_scan
      secruity_software
    ].any? { |name| __send__("#{name}_problem?") }
  end

  def unknown?
    %w[
      existence
      content
      os_update
      app_update
      security_update
      security_scan
      security_software
    ].any? { |name| self[name] == 'unknown' }
  end

  def status
    if confirmed_at.blank?
      :unconfirmed
    elsif expiration <= Time.current
      :expired
    elsif !approved
      :unapproved
    elsif expiration <= Time.current.days_since(30)
      :expire_soon
    else
      :approved
    end
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

  def validity_period
    if approved
      396.days
    else
      30.days
    end
  end

  def check_and_approve!
    if !exist?
      self.content = :unknown
      self.os_update = :unknown
      self.app_update = :unknown
      self.security_software = nil
      self.security_update = :unknown
      self.security_scan = :unknown
    elsif node.virtual?
      self.os_update = :unknown
      self.app_update = :unknown
      self.security_software = nil
      self.security_update = :unknown
      self.security_scan = :unknown
    elsif security_software.nil?
      self.security_update = :unknown
      self.security_scan = :unknown
    end

    self.approved = approvable?

    self.confirmed_at = Time.current
    self.expiration = Time.current + validity_period
  end
end
