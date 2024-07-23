module Ipv6Config
  extend ActiveSupport::Concern

  IDENTIFIER_TYPES = {
    dynamic: "d",
    reserved: "r",
    static: "s",
    mapped: "p",
    manual: "m",
    disabled: "!",
  }.freeze

  included do
    enum :ipv6_config, {
      dynamic: 0,
      reserved: 1,
      static: 2,
      mapped: 4,
      manual: 8,
      disabled: -1,
    }, prefix: :ipv6, validates: true
  end

  def ipv6_config_prefix
    Ipv6Config::IDENTIFIER_TYPES.fetch(ipv6_config.intern)
  end
end
