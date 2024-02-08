module SearchHelper
  def filter_link(attr, model = nil)
    controller_name =
      if model.nil?
        controller.controller_name
      elsif model.is_a?(ActiveRecord)
        model.class.class_name.tableize
      else
        model.class_name.tableize
      end

    params = {
      query: @query,
      # page: @page,
      per: @per,
      order: @order.to_h,
      condition: @condition.to_h,
    }
    i_class = []

    case @condition&.[](attr)
    when "true"
      params[:condition][attr] = false
      i_class << "far" << "fa-check-square"
    when "false"
      params[:condition].delete(attr)
      i_class << "far" << "fa-square"
    else
      params[:condition][attr] = true
      i_class << "fas" << "fa-filter"
    end

    path = __send__("#{controller_name}_path", params)
    link_to path, class: "btn btn-sm btn-light" do
      tag.i("", class: i_class)
    end
  end

  def filter_collection_select(attr, collection, value_method, text_method, **options)
    bootstrap_form_tag url: public_send("#{controller.controller_path}_path"), method: "get" do |f|
      content = "".html_safe
      content += f.hidden_field("query", value: @query) if @query.present?
      content += f.hidden_field("per", value: @per) if @per.present?
      @order&.each do |name, value|
        content += f.hidden_field("order[#{name}]", value: value)
      end
      @condition&.each do |name, value|
        next if name.intern == attr.intern

        content += f.hidden_field("condition[#{name}]", value: value)
      end
      content += f.collection_select(
        "condition[#{attr}]", collection, value_method, text_method, include_blank: "(全て)",
        selected: @condition&.fetch(attr, nil), hide_label: true, wrapper_class: "col-12 mb-3",
        append: f.primary('<i class="fas fa-filter"></i>'.html_safe, name: :filter, render_as_button: true),
        **options)
      content
    end
  end

  def sort_link(attr, model = nil)
    controller_name =
      if model.nil?
        controller.controller_name
      elsif model.is_a?(ActiveRecord)
        model.class.class_name.tableize
      else
        model.class_name.tableize
      end

    params = {
      query: @query,
      page: @page,
      per: @per,
      order: {},
      condition: @condition.to_h,
    }
    i_class = ["fas"]

    case @order&.[](attr)
    when "asc"
      params[:order][attr] = "desc"
      i_class << "fa-sort-down"
    when "desc"
      i_class << "fa-sort-up"
    else
      params[:order][attr] = "asc"
      i_class << "fa-sort"
    end

    path = __send__("#{controller_name}_path", params)
    link_to path do
      tag.i("", class: i_class)
    end
  end
end
