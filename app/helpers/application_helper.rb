module ApplicationHelper
  NAME_COLORS = {
    dynamic: "success",
    reserved: "secondary",
    static: "primary",
    manual: "warning",
    disabled: "light",
    locked: "dark",
    auth: "primary",
    global: "danger",
    virtual: "secondary",
    specific: "warning",
    public: "primary",
    dns: "success",
    dhcp: "secondary",
    deleted: "danger",
  }

  def site_title
    Settings.site.title || t(:nodokan)
  end

  # traslation
  def t_enums(attr, model = nil)
    model_class =
      if model.nil?
        controller.controller_name.classify.constantize
      elsif model.is_a?(ActiveRecord)
        model.class
      else
        model
      end
    model_class.__send__(attr).keys.index_with do |key|
      t_enum(key, attr)
    end
  end

  def t_enum(value, attr)
    t(value, scope: [:activerecord, :enums, attr])
  end

  def t_bitwises(attr, model = nil)
    model_class =
      if model.nil?
        controller.controller_name.classify.constantize
      elsif model.is_a?(ActiveRecord)
        model.class
      else
        model
      end
    model_class.__send__(attr).keys.index_with do |key|
      t_bitwise(key, attr)
    end
  end

  def t_bitwise(value, attr)
    t(value, scope: [:activerecord, :bitwises, attr])
  end


  def t_floor(number)
    if number.zero?
      t("helpers.floor.zero")
    elsif number == 1
      t("helpers.floor.one")
    elsif number > 1
      t("helpers.floor.positive", number: number)
    else
      t("helpers.floor.negative", number: - number)
    end
  end

  # build node
  def dt_col
    %w[col-sm-6 col-md-4 col-lg-3 col-xl-2 col-print-full]
  end

  def dd_col
    %w[col-sm-6 col-md-8 col-lg-9 col-xl-10 col-print-full]
  end

  def dt_dd_tag(term, &block)
    tag.div(class: "row border-bottom mb-2 pb-2") do
      tag.dt(term, class: dt_col) +
        tag.dd(class: dd_col + ["mb-0"], &block)
    end
  end

  def dt_dd_for(recored, attr, **opts)
    if block_given?
      dt_dd_tag recored.class.human_attribute_name(attr) do
        yield recored.__send__(attr)
      end
    else
      dt_dd_for(recored, attr, **opts) do |value|
        span_value_for(value, **opts)
      end
    end
  end

  def span_value_for(value, **opts)
    case value
    when nil
      tag.span(opts[:blank_alt] || t("values.none"), class: "font-italic text-muted") unless opts[:hide_blank]
    when "", [], {}
      tag.span(opts[:blank_alt] || t("values.empty"), class: "font-italic text-muted") unless opts[:hide_blank]
    when String
      case opts[:format]
      when :translate
        span_text_tag(t(value, scope: opts[:scope]), **opts)
      else
        span_text_tag(value, **opts)
      end
    when Time, Date, DateTime, ActiveSupport::TimeWithZone
      span_text_tag(l(value, format: opts[:format]), **opts)
    when true, false
      span_text_tag(**opts) do
        i_bool_tag(value)
      end
    when Array
      tag.ul(class: "list-inline mb-0") do
        list_html = sanitize("")
        value.each do |v|
          list_html += tag.li(class: "list-inline-item border border-primary rounded px-1 mb-1") do
            span_value_for(v, **opts)
          end
        end
        list_html
      end
    when IPAddress
      opts[:class] ||= []
      case value
      when IPAddress::IPv4
        opts[:class] << "text-danger" unless value.private?
      when IPAddress::IPv6
        opts[:class] << "text-danger" unless value.unique_local?
      end

      # BUG: IPAddress::IPv6#network? is not correct when prefix == 128
      if value.network? && value.prefix < 128
        span_text_tag(value.to_string, **opts)
      else
        span_text_tag(value.to_s, **opts)
      end
    when ApplicationRecord
      link_to(value.to_s, value)
    when ActiveRecord::Associations::CollectionProxy
      span_value_for(value.to_a, **opts)
    else
      span_text_tag(value.to_s, **opts)
    end
  end

  def span_text_tag(value = nil, around: nil, line_break: false, **opts, &block)
    if around.present?
      tag.span(around[0], class: "text-muted") +
        span_text_tag(value, **opts, &block) +
        tag.span(around[1], class: "text-muted")
    elsif line_break
      tag_list = value.each_line.flat_map do |line|
        [tag.span(line, **opts, &block), tag.br]
      end
      tag_list.pop
      tag_list.inject { |result, item| result + item }
    else
      tag.span(value, **opts, &block)
    end
  end

  def i_bool_tag(value)
    if value
      tag.i("", class: "far fa-check-square")
    else
      tag.i("", class: "far fa-square")
    end
  end

  def html_month(time)
    time.strftime("%Y-%m")
  end

  def html_date(time)
    time.strftime("%Y-%m-%d")
  end

  def html_time(time, second: true)
    if second
      time.strftime("%H:%M:%S")
    else
      time.strftime("%H:%M")
    end
  end

  def html_datetime_local(time, second: true)
    if second
      time.strftime("%Y-%m-%dT%H:%M:%S")
    else
      time.strftime("%Y-%m-%dT%H:%M")
    end
  end

  def html_datetime_zone(time)
    time.xmlschema
  end

  def badge(name, id: nil, level: :primary, enabled: true, hidden: false)
    return if hidden

    badge_classes = ["badge"]
    if enabled
      badge_classes << "bg-#{level}"
    else
      badge_classes << "bg-light" << "text-muted"
    end
    tag.span(name, class: badge_classes, id: id)
  end

  def badge_boolean(model, attr, id: nil, level: :primary, disabled_show: false)
    enabled = model.__send__(attr)
    return if !disabled_show && !enabled

    name = model.class.human_attribute_name(attr)
    badge_classes = ["badge"]
    if enabled
      badge_classes << "bg-#{level}"
    else
      badge_classes << "bg-light" << "text-muted"
    end
    tag.span(name, class: badge_classes, id: id)
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

    # queryは設定しない
    params = {
      page: @page,
      per: @per,
      order: {},
      condition: @condition&.to_h || {},
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
    link_to path, class: "btn btn-sm btn-light" do
      tag.i("", class: i_class)
    end
  end

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
      page: @page,
      per: @per,
      order: @order&.to_h || {},
      condition: @condition&.to_h || {},
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

  def badge_for(value, scope: "", badge_class: [])
    badge_class = badge_class.to_s.split unless badge_class.is_a?(Array)
    badge_class << "badge"
    NAME_COLORS[value.intern]&.then { |color| badge_class << "bg-#{color}" }
    tag.span(t(value, scope: scope), class: badge_class)
  end

  def sp(number = 1)
    # rubocop:disable Rails/OutputSafety
    ("&nbsp;" * number).html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
