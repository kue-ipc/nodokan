module NetworksHelper
  def pool_range(pool)
    case pool
    when IpPool
      "#{pool.ip_first_address}-#{pool.ip_last_address}"
    when Ip6Pool
      "#{pool.ip6_first_address}-#{pool.ip6_last_address}"
    else
      pool.range.then { |r| "#{r.first}-#{r.last}"}
    end
  end
end
