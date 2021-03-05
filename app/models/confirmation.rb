class Confirmation < ApplicationRecord
  belongs_to :node
  belongs_to :security_software, optional: true

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
    %w[
      existence
      content
      os_update
      app_update
      security_update
      security_scan
    ].any? { |name| __send__("#{name}_unknown?") } || security_software.nil?
  end

  def problem?
    %w[
      existence
      content
      os_update
      app_update
      security_update
      security_scan
    ].any? { |name| __send__("#{name}_before_type_cast") >= 16 } ||
      !secruity_software&.approved
  end

  def approvable?
    !unknown? && !problem?
  end
end
