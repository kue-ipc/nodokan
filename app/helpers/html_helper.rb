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
    logical: "secondary",
    specific: "warning",
    public: "primary",
    dns: "success",
    dhcp: "secondary",
    deleted: "danger",
    virtual_machine: "info",
  }.freeze

  def dt_col
    %w(col-sm-6 col-md-4 col-lg-3 col-xl-2 col-print-full)
  end

  def dd_col
    %w(col-sm-6 col-md-8 col-lg-9 col-xl-10 col-print-full)
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
          class: "font-italic text-muted")
      end
    when "", [], {}
      unless opts[:hide_blank]
        tag.span(opts[:blank_alt] || t("values.empty"),
          class: "font-italic text-muted")
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
      opts[:class] << "text-danger" unless value.private?
      str = value.to_s
      if (value.ipv4? && value.prefix < 32) ||
          (value.ipv6? && value.prefix < 128)
        str += "/#{value.prefix}"
      end
      span_text_tag(str, **opts)
    when ApplicationRecord
      link_to(value.to_s, value, data: {turbo: false})
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
      tag_list = value.each_line
        .flat_map { |line| [tag.span(line, **opts, &block), tag.br] }
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

  def badge_for(value, scope: "", badge_class: [])
    badge_class = badge_class.to_s.split unless badge_class.is_a?(Array)
    badge_class << "badge"
    NAME_COLORS[value.intern]&.then do |color|
      badge_class << "bg-#{color}"
    end
    tag.span(t(value, scope: scope), class: badge_class)
  end

  def sp(number = 1)
    # rubocop:disable Rails/OutputSafety
    ("&nbsp;" * number).html_safe
    # rubocop:enable Rails/OutputSafety
  end

  GRID_TIERS = [:xs, :sm, :md, :lg, :xl, :xxl].freeze

  def grid_classes(grid)
    classes = []
    grid.zip(HtmlHelper::GRID_TIERS).flat_map do |size, tier|
      next if size.nil?

      pre_tiers = HtmlHelper::GRID_TIERS.take_while { |t| t != tier }.reverse
      none_tier = pre_tiers
        .find { |t| classes.include?(display_class(:none, tier: t)) }
      block_display = none_tier.nil? || pre_tiers
        .take_while { |t| t != none_tier }
        .any? { |t| classes.include?(display_class(:block, tier: t)) }

      if size.zero?
        classes << display_class(:none, tier: tier) if block_display
      else
        classes << display_class(:block, tier: tier) unless block_display
        classes << col_class(size, tier: tier)
      end
    end
    classes
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
