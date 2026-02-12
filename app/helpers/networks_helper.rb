module NetworksHelper
  def network_flag_names
    %i[disabled unverifiable auth locked specific global]
  end

  def pool_range(pool)
    case pool
    when Ipv4Pool
      "#{pool.ipv4_first_address}-#{pool.ipv4_last_address}"
    when Ipv6Pool
      "#{pool.ipv6_first_address}-#{pool.ipv6_last_address}"
    else
      pool.range.then { |r| "#{r.first}-#{r.last}" }
    end
  end
end
