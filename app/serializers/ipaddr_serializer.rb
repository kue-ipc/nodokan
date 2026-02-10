class IpaddrSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(ip)
    hash = {
      "addr" => ip.to_i,
      "prefix" => ip.prefix,
      "family" => ip.family,
    }
    hash["zone_id"] = ip.zone_id if ip.ipv6?
    super(hash)
  end

  def deserialize(hash)
    ip = IPAddr.new(hash["addr"], hash["family"])
    ip.prefix = hash["prefix"]
    ip.zone_id = hash["zone_id"] if hash["zone_id"]
    ip
  end

  def klass
    IPAddr
  end
end
