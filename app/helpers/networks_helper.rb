module NetworksHelper
  def pool_range(pool)
    case pool
    when IpPool
      "#{pool.first_address}-#{pool.last_address}"
    when Ip6Pool
      "#{pool.first6_address}-#{pool.last6_address}"
    else
      pool.range.then { |r| "#{r.first}-#{r.last}"}
    end
  end
end
