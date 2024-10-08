module HtmlHelper
  NAME_COLORS = {
    dynamic: "success",
    reserved: "secondary",
    static: "primary",
    mapped: "info",
    manual: "warning",
    disabled: "light",
    locked: "dark",
    auth: "primary",
    global: "danger",
    deleted: "danger",
    normal: "light",
    mobile: "dark",
    virtual: "info",
    logical: "secondary",
    specific: "warning",
    public: "primary",
    dns: "success",
    dhcp: "secondary",
    router: "dark",
    unmanaged: "warning",
    managed: "success",
    assist: "info",
    stateless: "primary",
  }.freeze

  def name_color(value)
    NAME_COLORS[value.intern] || "primary"
  end

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
      unless opts[:hide_blank]
        tag.span(opts[:blank_alt] || t("values.none"),
          class: opts[:blank_class] || "font-italic text-muted")
      end
    when "", [], {}
      unless opts[:hide_blank]
        tag.span(opts[:blank_alt] || t("values.empty"),
          class: opts[:blank_class] || "font-italic text-muted")
      end
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
        li_class = "list-inline-item border border-primary rounded px-1 mb-1"
        value.each do |v|
          list_html += tag.li(class: li_class) { span_value_for(v, **opts) }
        end
        list_html
      end
    when IPAddr
      opts[:class] ||= []
      global = case value.family
      in Socket::AF_INET
        !value.loopback? && !value.link_local? && !value.private? &&
          (1...224).cover?(value.to_i >> 24) # 1.0.0.0 <= ip < 224.0.0.0
      in Socket::AF_INET6
        value.to_i >> 125 == 1 # 2000::/3
      end
      opts[:class] << "text-danger-emphasis" if global
      opts[:class] << "text-warning-emphasis" if value.to_i.zero?

      str = value.to_s
      if (value.ipv4? && value.prefix < 32) ||
          (value.ipv6? && value.prefix < 128)
        str += "/#{value.prefix}"
      end
      span_text_tag(str, **opts)
    when ApplicationRecord
      if !opts[:no_link] && policy(value).show?
        link_to(span_text_tag(value.to_s, **opts), value, data: {turbo: false})
      else
        span_text_tag(value.to_s, **opts)
      end
    when ActiveRecord::Associations::CollectionProxy
      span_value_for(value.to_a, **opts)
    else
      span_text_tag(value.to_s, **opts)
    end
  end

  def span_text_tag(value = nil, around: nil, line_break: false, **, &)
    if around.present?
      tag.span(around[0], class: "text-muted") +
        span_text_tag(value, **, &) +
        tag.span(around[1], class: "text-muted")
    elsif line_break
      tag_list = value.each_line
        .flat_map { |line| [tag.span(line, **, &), tag.br] }
      tag_list.pop
      tag_list.inject { |result, item| result + item }
    else
      tag.span(value, **, &)
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

  def badge_tag(value, color: :primary, disbaled: false, hidden: false,
    **opts, &)
    opts = opts.dup
    badge_classes = opts.delete(:class) || []
    badge_classes = badge_classes.to_s.split unless badge_classes.is_a?(Array)

    badge_classes << "badge"
    if disbaled
      badge_classes << "bg-light" << "text-muted"
    else
      badge_classes << "text-bg-#{color}"
    end
    badge_classes << "d-none" if hidden

    tag.span(value, **opts, class: badge_classes, &)
  end

  def badge_for(record, attr, value = nil, disabled_show: false, **opts)
    opts = opts.dup
    opts[:class] ||= ["ms-1"]
    case record.class.type_for_attribute(attr)
    when ActiveRecord::Enum::EnumType
      value = record.__send__(attr) if value.nil?
      name = t_enum(value, attr)
      opts[:color] ||= name_color(value)
      if value == "disabled"
        opts[:disabled] ||= true
        opts[:hidden] ||= !disabled_show
      end
    when ActiveModel::Type::Boolean
      value = record.__send__(attr) if value.nil?
      name = record.class.human_attribute_name(attr)
      opts[:color] ||= name_color(attr)
      unless value
        opts[:disabled] ||= true
        opts[:hidden] ||= !disabled_show
      end
    when ActiveModel::Type::Integer
      value = record.__send__(attr) if value.nil?
      name = value
      opts[:color] ||= name_color(attr)
      if value.nil?
        opts[:disabled] ||= true
        opts[:hidden] ||= !disabled_show
      end
    else
      raise "unsupported type: #{attr}"
    end
    badge_tag(name, **opts)
  end

  def sp(number = 1)
    # rubocop:disable Rails/OutputSafety
    ("&nbsp;" * number).html_safe
    # rubocop:enable Rails/OutputSafety
  end

  GRID_TIERS = [:xs, :sm, :md, :lg, :xl, :xxl].freeze

  def col_grid_class(col)
    (col[:class] || []) + grid_class(col[:grid] || [])
  end

  def grid_class(grid)
    class_list = []
    pre_block_display = true
    grid.zip(HtmlHelper::GRID_TIERS).each do |size, tier|
      next if size.nil?

      if size.zero?
        class_list << display_class(:none, tier:) if pre_block_display
        pre_block_display = false
      else
        class_list << display_class(:block, tier:) unless pre_block_display
        class_list << col_class(size, tier:)
        pre_block_display = true
      end
    end
    class_list
  end

  def display_class(display, tier: nil)
    if tier && tier.intern != :xs
      "d-#{tier}-#{display}"
    else
      "d-#{display}"
    end
  end

  def col_class(size, tier: nil)
    if tier && tier.intern != :xs
      "col-#{tier}-#{size}"
    else
      "col-#{size}"
    end
  end
end
