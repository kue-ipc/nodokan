class Confirmation < ApplicationRecord
  belongs_to :node
  belongs_to :security_software

  enum existence: {
    existing: 0,
    abandoned: 16,
    missing: 17,
    not_my_own: 18,
    unknown: 255,
  }, _prefix: true

  enum content: {
    correct: 0,
    incorrect: 16,
    unknown: 255,
  }, _prefix: true

  enum os_update: {
    auto: 0,
    manual: 1,
    unnecessary: 8,
    not_do: 16,
    eol: 17,
    unknown: 255,
  }, _prefix: true

  enum app_update: {
    auto: 0,
    manual: 1,
    unnecessary: 8,
    not_do: 16,
    eol: 17,
    unknown: 255,
  }, _prefix: true

  enum security_update: {
    auto: 0,
    not_implemented: 9,
    not_do: 16,
    eol: 17,
    unknown: 255,
  }, _prefix: true

  enum security_scan: {
    auto: 0,
    manual: 1,
    not_implemented: 9,
    not_do: 16,
    unknown: 255,
  }, _prefix: true
end
