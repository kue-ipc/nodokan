# use ransack
module Search
  extend ActiveSupport::Concern
  include Page

  class_methods do
    def search_for(model)
      @search_model = model
    end

    def search_model
      @search_model || (raise "No search model")
    end
  end

  def search_model
    self.class.search_model
  end

  private def set_search(order: nil, condition: nil, page: nil, per: nil)
    @query = params[:query]&.to_s
    @condition = params[:condition].presence
      &.permit(search_condition_permittied_attributes) ||condition
    @order = params[:order].presence
      &.permit(search_order_permitted_attributes) || order
    set_page(page:, per:)

    @search_params = {
      query: @query,
      condition: @condition&.to_h,
      order: @order&.to_h,
      **@page_params,
    }
  end

  def search_params
    @search_params || (raise "No set_search")
  end

  private def search(scope)
    ransack_q = {}
    ransack_q.merge!(search_ransack_query(@query, matcher: "cont"))
    ransack_q.merge!(search_ransack_condition(@condition))
    q = scope.ransack(ransack_q, auth_object: current_user.role)
    q.sorts = search_sorts_order(@order) if @order.present?
    # has_manyがあると重複するのでdistinctを付ける
    paginate(q.result.distinct)
  end

  ## query

  private def search_ransack_query(query, matcher: "cont")
    return {} if query.blank?

    address = begin
      IPAddr.new(query)
    rescue StandardError
      nil
    end

    if address
      if address.ipv4?
        search_ransack_query_ipv4(search_attributes_by_type[:ipv4], address)
      elsif address.ipv6?
        search_ransack_query_ipv6(search_attributes_by_type[:ipv6], address)
      end
    elsif query =~ /\A\h{2}(?:[-.:]?\h{2}){5,}\z/
      search_ransack_query_binary(search_attributes_by_type[:binary],
        [query.delete("-.:")].pack("H*"))
    end.presence || search_ransack_query_string(
      search_attributes_by_type.slice(:string, :text).values.flatten, query,
      matcher:)
  end

  private def search_ransack_query_string(keys, str, matcher: "cont")
    return {} if keys.blank?

    {"#{keys.join('_or_')}_#{matcher}" => str}
  end

  # FIXME: 最後のオクテットが\0だと切り詰められる
  # TODO: /32以外の場合は範囲検索にしたい
  private def search_ransack_query_ipv4(keys, address)
    return {} if keys.blank?

    {"#{keys.join('_or_')}_start" => address.hton}
  end

  private def search_ransack_query_ipv6(keys, address)
    search_ransack_query_ipv4(keys, address)
  end

  private def search_ransack_query_binary(keys, data)
    return {} if keys.blank?

    {"#{keys.join('_or_')}_start" => data}
  end

  ## condition

  private def search_condition_permittied_attributes
    search_attributes_by_type.values.flatten
  end

  # https://activerecord-hackery.github.io/ransack/getting-started/search-matches/
  private def search_ransack_condition(condition)
    return {} if condition.blank?

    condition.compact_blank.to_h do |key, value|
      type = search_model.type_for_attribute(key)
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
  private def search_attributes_by_type
    @search_attributes_by_type ||= model_attributes_by_type(search_model)
  end

  private def model_attributes_by_type(model, exclude_association: false)
    attributes_by_type = model.ransackable_attributes.group_by do |name|
      type = model.type_for_attribute(name).type
      if type == :binary && name.end_with?("_data")
        type = [:ipv4, :ipv6].find do |special_type|
          name.start_with?("#{special_type}_")
        end || type
      end
      type
    end

    unless exclude_association
      model.ransackable_associations.each do |association|
        model_attributes_by_type(
          association.classify.constantize, exclude_association: true)
          .each do |type, attributes|
          attributes_by_type[type] ||= []
          attributes_by_type[type].concat(
            attributes.map { |name| [association, name].join("_") })
        end
      end
    end

    attributes_by_type
  end

  ## order

  private def search_order_permitted_attributes
    search_sortable_attributes + search_sortable_attributes
      .map { |name| name.dup.delete_suffix!("_data") }.compact
  end

  private def search_sorts_order(order)
    attributes = search_sortable_attributes.to_set
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

  private def search_sortable_attributes
    @search_sortable_attributes ||= model_sortable_attributes(search_model)
  end

  private def model_sortable_attributes(model, exclude_association: false)
    attributes = model.ransortable_attributes(current_user.role)

    unless exclude_association
      model.ransackable_associations.each do |association|
        attributes.concat(
          model_sortable_attributes(association.classify.constantize,
            exclude_association: true)
          .map { |name| [association, name].join("_") })
      end
    end

    attributes
  end
end
