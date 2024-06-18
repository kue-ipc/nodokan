# abstract job class
class RadiusJob < ApplicationJob
  # Radius関係のレコードを更新するとき専用
  # NOTE: テーブルがVIEWであるため、作成時に `id: nil` を設定する必要がある
  def update_radius_user(model_class, username:, **params)
    primary_key = model_class.primary_key&.intern || :id
    record = model_class.find_by(username: username)
    if record
      # 重複するデータがある場合は事前に削除しておく。
      model_class.where(username: username).where
        .not(primary_key => record.__send__(primary_key)).destroy_all
      record.update!(**params)
    else
      model_class.create!(primary_key => nil, username: username, **params)
    end
  end
end
