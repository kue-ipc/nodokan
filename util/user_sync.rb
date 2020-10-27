#!/usr/bin/env rails runner

require 'net/ldap'

if $0 == __FILE__
  entry_list = Devise::LDAP::Adapter.ldap_connect(nil).ldap.search(
    filter: '(objectClass=posixAccount)'
  ).map(&:uid).map(&:first)

  logger = Logger.new(STDERR)
  logger.level = Logger::DEBUG

  entry_list.each do |username|
    if User.find_by(username: username)
      logger.debug("登録済み: #{username}")
      next
    end

    user = User.new(username: username)

    unless user.sync_ldap!
      logger.warn("登録不可: #{username}")
      next
    end

    unless user.save
      logger.error("登録エラー: #{username}")
    end

    logger.info("登録完了: #{username}")
  end
end
