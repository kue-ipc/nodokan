class Confirmation < ApplicationRecord
  belongs_to :user
  belongs_to :node
  belongs_to :security_software

  enum existence: {
    existing: 0,
    abandoned: 1,
    missing: 2,
    not_my_own: 3,
    unknown: 255,
  }, _prefix: true

  enum content: {
    correct: 0,
    incorrect: 1,
    unknown: 255,
  }, _prefix: true

  enum os_update: {
    auto: 0,
    manual: 1,
    not: 2,
    eol: 3,
    unknown: 255,
  }, _prefix: true

  enum ms_update: {
    auto: 0,
    manual: 1,
    not: 2,
    eol: 3,
    unknown: 255,
  }, _prefix: true

  enum store_update: {
    auto: 0,
    manual: 1,
    not: 2,
    eol: 3,
    unknown: 255,
  }, _prefix: true

  enum software_update: {
    auto: 0,
    manual: 1,
    not: 2,
    eol: 3,
    unknown: 255,
  }, _prefix: true

  enum security_update: {
    auto: 0,
    manual: 1,
    not: 2,
    eol: 3,
    unknown: 255,
  }, _prefix: true

  def approved?
    result = true

    case existence
    when 'abandoned'
      errors.add(:existence, '廃棄済みの端末は「削除」してください。削除することで、確認が不要になります。')
      return false
    when 'missing'
      errors.add(:existence, '端末が行方不明の状態では、確認を完了することができません。端末を見つけるか、すでに廃棄済みかを確認してください。')
      return false
    when 'not_my_own'
      errors.add(:existence, '端末の管理者があなた以外の場合は、管理を移譲する必要があります。「移譲」を実施してください。移譲先が不明の場合は、管理者に連絡してください。')
      return false
    when 'unknown'
      errors.add(:existence, '状況がわからない場合は、管理者にお問い合わせください。')
      return false
    end

    if registered_content
      errors.add(:existence, '端末が見つからない場合は、。削除後の確認は不要です。')
      false
    end
  end
end
