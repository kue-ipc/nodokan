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
    unnecessary: 8,
    not_do: 16,
    eol: 17,
    unknown: -1,
  }, _prefix: true

  enum app_update: {
    auto: 0,
    manual: 1,
    unnecessary: 8,
    not_do: 16,
    eol: 17,
    unknown: -1,
  }, _prefix: true

  enum security_update: {
    auto: 0,
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

  def existence_ok?
    existence_existing?
  end

  def content_ok?
    content_correct?
  end

  def os_update_ok?
    os_update_auto? ||
      os_update_manual? ||
      os_update_unnecessary?
  end

  def app_update_ok?
    app_update_auto? ||
      app_update_manual? ||
      app_update_unnecessary?
  end

  def security_update_ok?
    security_update_auto? ||
      security_update_not_implemented?
  end

  def security_scan_ok?
    security_scan_auto? ||
      security_scan_manual? ||
      security_scan_not_implemented?
  end

  def security_software_ok?
    security_software&.approved
  end

  def existence_problem?
    existence_abandoned? ||
      existence_unnecessary? ||
      existence_missing? ||
      existence_not_my_own?
  end

  def content_problem?
    content_incorrect?
  end

  def os_update_problem?
    os_update_not_do? ||
      os_update_eol?
  end

  def app_update_problem?
    app_update_not_do? ||
      app_update_eol?
  end

  def security_update_problem?
    security_update_not_do? ||
      security_update_eol?
  end

  def security_scan_problem?
    security_scan_not_do?
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
