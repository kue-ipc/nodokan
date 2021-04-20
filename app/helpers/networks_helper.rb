module NetworksHelper
  def pool_range(pool)
    case pool
    when Ipv4Pool
      "#{pool.ipv4_first_address}-#{pool.ipv4_last_address}"
    when Ipv6Pool
      "#{pool.ipv6_first_address}-#{pool.ipv6_last_address}"
    else
      pool.range.then { |r| "#{r.first}-#{r.last}"}
    end
  end

  def sort_link(attr)
    params = {
      page: @page,
      per: @per,
      order: {},
      condition: @condition&.to_h || {} 
    }
    i_class = ['fas']

    case @order&.[](attr)
    when 'asc'
      params[:order][attr] = 'desc'
      i_class << 'fa-sort-down'
    when 'desc'
      i_class << 'fa-sort-up'
    else
      params[:order][attr] = 'asc'
      i_class << 'fa-sort'
    end
    link_to networks_path(params), class: 'btn btn-sm btn-light' do
      content_tag(:i, '', class: i_class)
    end
  end

  def filter_link(attr)
    params = {
      page: @page,
      per: @per,
      order: @order&.to_h || {},
      condition: @condition&.to_h || {} 
    }
    i_class = []

    case @condition&.[](attr)
    when 'true'
      params[:condition][attr] = false
      i_class << 'far' << 'fa-check-square'
    when 'false'
      params[:condition].delete(attr)
      i_class << 'far' << 'fa-square'
    else
      params[:condition][attr] = true
      i_class << 'fas' << 'fa-filter'
    end
    link_to networks_path(params), class: 'btn btn-sm btn-light' do
      content_tag(:i, '', class: i_class)
    end
  end
end
