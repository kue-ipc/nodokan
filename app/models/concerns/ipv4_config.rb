module Ipv4Config
  extend ActiveSupport::Concern

  IDENTIFIER_TYPES = {
    dynamic: "d",
    reserved: "r",
    static: "s",
    manual: "m",
    disabled: "!",
  }.freeze

  included do
    enum :ipv4_config, {
      dynamic: 0,
      reserved: 1,
      static: 2,
      manual: 8,
      disabled: -1,
    }, prefix: :ipv4, validate: true
  end

  def ipv4_config_prefix
    Ipv4Config::IDENTIFIER_TYPES.fetch(ipv4_config.intern)
  end

  class_methods do
    def ipv4_config_from_prefix(prefix)
      Ipv4Config::IDENTIFIER_TYPES.key(prefix)
    end
  end
end
