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

    condition.select do |key, value|
      value.present?
    end.to_h do |key, value|
      type = self.class.search_model.type_for_attribute(key)
      case type.type
      when :string, :text, :integer, :float, :decimal, :datetime, :date, :time
        ["#{key}_eq", value]
      when :binary
        ["#{key}_eq", [value].pack("H*")]
      when :boolean
        ["#{key}_true", value]
      else
        logger.warn "Unknown attribute type: #{type.type}"
        ["#{key}_eq", value]
      end
    end
  end

  private def search_order(order)
    order.to_h.map do |k, v|
      k = "#{k}_data" if k.start_with?("ipv4", "ipv6", "mac_address", "duid") && !k.end_with?("_data")
      v = v.to_s.downcase
      "#{k} #{v}" if ["asc", "desc"].include?(v)
    end
  end

  class_methods do
    def search_for(model)
      @search_model = model
    end

    def search_model
      @search_model || (raise "No search model")
    end

    def search_query_attributes
      search_model.ransackable_attributes.select do |name|
        [:string, :text, :binary].include?(search_model.type_for_attribute(name).type)
      end
    end

    def search_order_attributes
      search_model.ransortable_attributes.map do |name|
        name.delete_suffix("_data")
      end
    end

    def search_condition_attributes
      search_model.ransackable_attributes
    end
  end
end
