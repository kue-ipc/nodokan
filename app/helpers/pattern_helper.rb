# ECMAScript v flag RegExp
module PatternHelper
  def mac_address_pattern
    "[0-9A-Fa-f]{2}(?:[\\-.:]?[0-9A-Fa-f]{2}){5}"
  end

  def ipv4_address_pattern
    "(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])" \
      "(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}"
  end

  def ipv6_address_pattern
    "(?:[0-9A-Fa-f](?![0-9A-Fa-f]{4})|:(?!:{2})){2,39}"
  end

  def duid_pattern
    "[0-9A-Fa-f]{2}(?:[\\-.:]?[0-9A-Fa-f]{2}){3,127}"
  end
end
