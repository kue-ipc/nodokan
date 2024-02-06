# use ransack
module Search
  extend ActiveSupport::Concern

  private def set_search
    @query = params[:query]&.to_s
    @order = params.require(:order).permit(self.class.search_order_attributes) if params[:order].present?
    if params[:condition].present?
      @condition = params.require(:condition).permit(self.class.search_condition_attributes)
    end
  end

  private def search_and_sort(scope)
    ransack_q = {}
    ransack_q.merge!(search_query(@query, matcher: "cont"))
    ransack_q.merge!(search_condition(@condition))
    q = scope.ransack(ransack_q)
    q.sorts = search_order(@order) if @order.present?
    q.result
  end

  # private def search_query(query, matcher: "cont")
  #   {"#{self.class.search_query_attributes.join('_or_')}_#{matcher}" => query}
  # end

  private def search_query(query, matcher: "cont")
    return {} if query.blank?

    keys = self.class.search_query_attributes
    address = begin
      IPAddr.new(query)
    rescue StandardError
      nil
    end
    if address
      if address.ipv4?
        ipv4_keys = keys.select { |key| key.start_with?("ipv4") }
        return {"#{ipv4_keys.join('_or_')}_eq" => address.hton} if ipv4_keys.present?
      elsif address.ipv6?
        ipv6_keys = keys.select { |key| key.start_with?("ipv6") }
        return {"#{ipv6_keys.join('_or_')}_eq" => address.hton} if ipv6_keys.present?
      end
    elsif query =~ /\A\h{2}(?:[-.:]?\h{2}){5}\z/ && keys.inclrude?("mac_address_data")
      return {"mac_address_data_eq" => [query.delete("-.:")].pack("H*")}
    elsif query =~ /\A\h{2}(?:[-:]\h{2}){6,}\z/ && keys.include?("duid_data")
      return {"duid_data_eq" => [query.delete("-.:")].pack("H*")}
    end
    {"#{keys.join('_or_')}_#{matcher}_any" => query}
  end

  # https://activerecord-hackery.github.io/ransack/getting-started/search-matches/
  private def search_condition(condition)
    return {} if condition.blank?

    condition.to_h do |k, v|
      next [k, nil] if v.blank?

      type = model.type_for_attribute(k)
      case type.type
      when :string, :text, :integer, :float, :decimal, :datetime, :date, :time
        ["#{k}_eq", value]
      when :binary
        ["#{k}_eq", [value].pack("H*")]
      when :boolean
        ["#{k}_true", value]
      else
        logger.warn "Unknown attribute type: #{type.type}"
        [k, nil]
      end
    end.compact
  end

  private def search_order(order)
    order.to_h.map do |k, v|
      k = "#{k}_data" if k.start_with?("ipv4", "ipv6", "mac_address", "duid") && !k.end_with?("_data")
      v = v.to_s.downcase
      "#{k} #{v}" if ["asc", "desc"].include?(v)
    end
  end
end
