module NodeSearchHelper
  # rubocop: disable Layout
  NODE_SEARCH_RESULTS_COL_CLASSES = {
    action:       %w(            col-2 col-md-1 col-xl-1),
    name:         %w(            col-6 col-md-5 col-xl-3),
    hostname:     %w(            col-4 col-md-3 col-xl-2),
    ipv4_address: %w(d-none d-md-block col-md-3 col-xl-2),
    ipv6_address: %w(d-none d-xl-block          col-xl-4),
  }.freeze
  # rubocop: enable Layout

  def node_search_form(attr, per: 10)
    bootstrap_form_with(
      method: "get",
      data: {turbo_frame: "#{dom_id(node)}_#{attr}-search"}) do |f|
      f.hidden_field("per", value: per) +
        f.search_field(
          :query,
          value: @query,
          hide_label: true,
          append: f.primary(
            '<i class="fas fa-search"></i>'.html_safe,
            name: :search,
            render_as_button: true))
    end
  end

  def node_search_result_col(name, value = nil, &block)
    tag.div(value, class: NODE_SEARCH_RESULTS_COL_CLASSES[name], &block)
  end
end
