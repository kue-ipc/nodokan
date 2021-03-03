class Confirmation < ApplicationRecord
  belongs_to :node
  belongs_to :security_software, required: false

  enum existence: {
    existing: 0,
    abandoned: 16,
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

  def exist?
    existence_existing?
  end

  def unknown?
    existence_unknown? || content_unknown? ||
      os_update_unknown? || app_update_unknown? ||
      security_update_unknown? || security_scan_unknown? ||
      security_software.nil?
  end

  def problem?
    Confirmation.existences[existence] >= 16 ||
    Confirmation.contents[content] >= 16 ||
    Confirmation.os_updates[os_update] >= 16 ||
    Confirmation.app_updates[app_update] >= 16 ||
    Confirmation.security_updates[security_update] >= 16 ||
    Confirmation.security_scans[security_scan] >= 16 ||
    !(secruity_software&.approved)
  end

  def approvable?
    !unknown? && !problem?
  end
end
