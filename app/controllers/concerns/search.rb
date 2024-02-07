# use ransack
module Search
  extend ActiveSupport::Concern

  private def set_search
    @query = params[:query]&.to_s
    @order = params.require(:order).permit(search_order_permitted_attributes) if params[:order].present?
    if params[:condition].present?
      @condition = params.require(:condition).permit(search_condition_permittied_attributes)
    end
  end

  private def search_and_sort(scope)
    ransack_q = {}
    ransack_q.merge!(search_query(@query, matcher: "cont"))
    ransack_q.merge!(search_condition(@condition))
    q = scope.ransack(ransack_q, auth_object: current_user.role)
    q.sorts = search_order(@order) if @order.present?
    # has_manyがあると重複するのでdistinctを付ける
    q.result.distinct
  end

  private def search_query(query, matcher: "cont")
    return {} if query.blank?

    address = begin
      IPAddr.new(query)
    rescue StandardError
      nil
    end

    if address
      if address.ipv4?
        search_query_ipv4(search_attributes_by_type[:ipv4], address)
      elsif address.ipv6?
        search_query_ipv6(search_attributes_by_type[:ipv6], address)
      end
    elsif query =~ /\A\h{2}(?:[-.:]?\h{2}){5,}\z/
      search_query_binary(search_attributes_by_type[:binary], [query.delete("-.:")].pack("H*"))
    end.presence ||
    search_query_string(search_attributes_by_type.slice(:string, :text).values.flatten, query,
      matcher: matcher)
  end

  private def search_query_string(keys, str, matcher: "cont")
    return {} if keys.blank?

    {"#{keys.join('_or_')}_#{matcher}" => str}
  end

  # FIXME: 最後のオクテットが\0だと切り詰められる
  # TODO: /32以外の場合は範囲検索にしたい
  private def search_query_ipv4(keys, address)
    return {} if keys.blank?

    {"#{keys.join('_or_')}_start" => address.hton}
  end

  private def search_query_ipv6(keys, address)
    search_query_ipv4(keys, address)
  end

  private def search_query_binary(keys, data)
    return {} if keys.blank?

    {"#{keys.join('_or_')}_start" => data}
  end

  # https://activerecord-hackery.github.io/ransack/getting-started/search-matches/
  private def search_condition(condition)
    return {} if condition.blank?

    condition.select do |_key, value|
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
    attributes = search_soartable_attributes.to_set
    dirs = ["asc", "desc"]
    order.to_h.map do |key, value|
      key = "#{key}_data" unless attributes.include?(key)
      value = value.to_s.downcase

      if attributes.include?(key) && dirs.include?(value)
        "#{key} #{value}"
      else
        logger.warn "spcific key or value is not valid: #{key} #{value}"
        nil
      end
    end.compact
  end

  def search_attributes_by_type
    @search_attributes_by_type ||= search_get_attributes_by_type
  end

  def search_get_attributes_by_type(model = self.class.search_model, exclude_association: false)
    attributes_by_type = model.ransackable_attributes.group_by do |name|
      type = model.type_for_attribute(name).type
      if type == :binary && name.end_with?("_data")
        type = [:ipv4, :ipv6].find { |special_type| name.start_with?("#{special_type}_") } || type
      end
      type
    end

    unless exclude_association
      model.ransackable_associations.each do |association|
        search_get_attributes_by_type(
          association.classify.constantize, exclude_association: true).each do |type, attributes|
          attributes_by_type[type] ||= []
          attributes_by_type[type].concat(attributes.map { |name| [association, name].join("_") })
        end
      end
    end

    attributes_by_type
  end

  def search_order_permitted_attributes
    search_soartable_attributes +
      search_soartable_attributes.map { |name| name.dup.delete_suffix!("_data") }.compact
  end

  def search_soartable_attributes
    @search_soartable_attributes ||= search_get_soartable_attributes
  end

  def search_get_soartable_attributes(model = self.class.search_model, exclude_association: false)
    attributes = model.ransortable_attributes(current_user.role)

    unless exclude_association
      model.ransackable_associations.each do |association|
        attributes.concat(
          search_get_soartable_attributes(association.classify.constantize, exclude_association: true)
          .map { |name| [association, name].join("_") })
      end
    end

    attributes
  end

  def search_condition_permittied_attributes
    search_attributes_by_type.values.flatten
  end

  class_methods do
    def search_for(model)
      @search_model = model
    end

    def search_model
      @search_model || (raise "No search model")
    end
  end
end
