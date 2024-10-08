module NodeSearchHelper
  NODE_SEARCH_LIST_COL_CLASSES = {
    name: %w[col-6 col-md-5 col-xl-3],
    hostname: %w[col-4 col-md-2 col-xl-2],
    ipv4_address: %w[d-none d-md-block col-md-3 col-xl-2],
    ipv6_address: %w[d-none d-xl-block col-xl-4],
    action: %w[col-2 col-md-2 col-xl-1],
  }.freeze

  def node_search_form_for(frame_prefix = "node", query: nil, per: nil,
    order: nil, condition: nil)
    turbo_frame_tag "#{frame_prefix}-search" do
      bootstrap_form_with(method: :get,
        data: {turbo_frame: "#{frame_prefix}-list"}) do |f|
        form_contents = "".html_safe
        form_contents += f.hidden_field("per", value: per) if per
        order&.each do |name, value|
          form_contents += f.hidden_field("order[#{name}]", value:)
        end
        condition&.each do |name, value|
          form_contents += f.hidden_field("condition[#{name}]", value:)
        end
        form_contents += f.search_field(:query, value: query.to_s,
          hide_label: true, append: f.primary(
            '<i class="fas fa-search"></i>'.html_safe,
            name: :search, render_as_button: true))
        form_contents
      end
    end
  end

  def node_search_list_for(nodes, frame_prefix = "node")
    turbo_frame_tag "#{frame_prefix}-list" do
      tag.div(class: "mb-2") {
        rows = tag.div(class: "row mb-2 fw-bold") {
          [
            *[:name, :hostname].map { |name|
              node_search_list_col(name, Node.human_attribute_name(name))
            },
            *[:ipv4_address, :ipv6_address].map { |name|
              node_search_list_col(name, Nic.human_attribute_name(name))
            },
            node_search_list_col(:action, t("messages.action")),
          ].inject(:+)
        }
        nodes.each do |node|
          rows += tag.div(class: "row py-1 border-top") {
            [
              node_search_list_col(:name, node_name_decorated(node)),
              node_search_list_col(:hostname, node.hostname),
              node_search_list_col(:ipv4_address,
                node_ipv4_address_decorated(node)),
              node_search_list_col(:ipv6_address,
                node_ipv6_address_decorated(node)),
              node_search_list_col(:action) { yield node },
            ].inject(:+)
          }
        end
        rows
      } + paginate(nodes) + tag.p(page_entries_info(nodes))
    end
  end

  def node_search_list_col(name, value = nil, &)
    if block_given?
      tag.div(class: NODE_SEARCH_LIST_COL_CLASSES[name], &)
    else
      tag.div(value, class: NODE_SEARCH_LIST_COL_CLASSES[name])
    end
  end
end
