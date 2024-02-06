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

  private def search_query(query, matcher: "cont")
    {"#{self.class.search_query_attributes.join('_or_')}_#{matcher}" => query}
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
      v = v.to_s.downcase
      "#{k} #{v}" if ["asc", "desc"].include?(v)
    end
  end
end
