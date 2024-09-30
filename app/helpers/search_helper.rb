module SearchHelper
  # 属性のタイプはbooleanであること
  # nil -> true -> false -> nil
  def filter_link(attr)
    params = controller.search_params.deep_dup
    params[:condition] ||= {}.with_indifferent_access
    # params.delete(:page)
    i_class = []

    case ActiveRecord::Type::Boolean.new.cast(params.dig(:condition, attr))
    in true
      params[:condition][attr] = false
      i_class << "far" << "fa-check-square"
    in false
      params[:condition].delete(attr)
      i_class << "far" << "fa-square"
    in nil
      params[:condition][attr] = true
      i_class << "fas" << "fa-filter"
    end

    path = public_send("#{controller.controller_path}_path", params)
    link_to path, class: "btn btn-sm btn-light" do
      tag.i("", class: i_class)
    end
  end

  def filter_collection_select(attr, collection, value_method, text_method,
    **options)
    params = controller.search_params.deep_dup
    bootstrap_form_tag(url: public_send("#{controller.controller_path}_path"),
      method: "get") do |f|
      content = "".html_safe
      content += f.hidden_field("query", value: params[:query])
      params[:condition]&.except(attr)&.each do |name, value|
        content += f.hidden_field("condition[#{name}]", value:)
      end
      params[:order]&.each do |name, value|
        content += f.hidden_field("order[#{name}]", value:)
      end
      # content += f.hidden_field("page", value: params[:page])
      content += f.hidden_field("per", value: params[:per])

      model_name = collection.first&.model_name&.human
      all_text =
        if model_name
          t("messages.all_of_model", model: model_name)
        else
          t("messages.all")
        end

      content += f.collection_select(
        "condition[#{attr}]", collection, value_method, text_method,
        include_blank: "(#{all_text})",
        selected: params.dig(:condition, attr),
        hide_label: true,
        wrapper_class: "col-12 mb-3",
        append: f.primary('<i class="fas fa-filter"></i>'.html_safe,
          name: :filter, render_as_button: true),
        **options)
      content
    end
  end

  # nil -> asc -> desc -> nil
  def sort_link(attr, model = nil)
    params = controller.search_params.deep_dup
    params[:order] ||= {}.with_indifferent_access
    i_class = []

    case params.dig(:order, attr).to_s.downcase
    in "asc"
      params[:order][attr] = "desc"
      i_class << "fas" << "fa-sort-down"
    in "desc"
      params[:order].delete(attr)
      i_class << "fas" << "fa-sort-up"
    else
      params[:order][attr] = "asc"
      i_class << "fas" << "fa-sort"
    end

    path = public_send("#{controller.controller_path}_path", params)
    link_to path do
      tag.i("", class: i_class)
    end
  end
end
