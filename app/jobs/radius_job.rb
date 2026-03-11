# abstract job class
class RadiusJob < ApplicationJob
  # Radius関係のレコードを更新するとき専用
  def update_radius_user(model_class, username, **params)
    model_class.transaction do
      primary_key = model_class.primary_key&.intern || :id
      if (record = model_class.find_by(username:))
        # 重複するレコードはすべて削除する
        model_class.where(username:).where.not(primary_key => record.__send__(primary_key)).destroy_all
        record.update!(**params)
      else
        # NOTE: テーブルがVIEWであるため、作成時に `id: nil` を設定する必要がある
        model_class.create!(primary_key => nil, username:, **params)
      end
    end
  end

  def add_radius_user(username, auth, vlan, groupname)
    raise "Cannot add the empty username to RADIUS" if username.blank?

    # Set password or LDAP
    case auth
    in {password: value}
      update_radius_user(Radius::Radcheck, username, attr: "Cleartext-Password", op: ":=", value:)
    in {type: value}
      update_radius_user(Radius::Radcheck, username, attr: "Auth-Type", op: ":=", value:)
    end
    # Set VLAN
    update_radius_user(Radius::Radreply, username, attr: "Tunnel-Private-Group-Id", op: ":=", value: vlan.to_s)
    # Set group
    update_radius_user(Radius::Radusergroup, username, groupname:, priority: 1)

    logger.info("Added a #{groupname} to RADIUS: #{username} - #{vlan}")
  end

  def del_radius_user(username)
    raise "Cannot delete the empty username from RADIUS" if username.blank?

    Radius::Radcheck.where(username:).destroy_all
    Radius::Radreply.where(username:).destroy_all
    Radius::Radusergroup.where(username:).destroy_all
  end
end
