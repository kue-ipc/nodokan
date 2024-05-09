class IpSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize?(argument)
    argument.is_a? IPAddr
  end

  def serialize(ip)
    # TODO: ipaddrのバージョンが上がれば IPAddr#cidr が使えるはず。
    super("#{ip}/#{ip.prefix}")
  end

  def deserialize(str)
    IPaddr.new(str)
  end
end
