module ApplicationHelper
  # traslation
  def t_enums(model_class, attr_name)
    model_class.__send__(attr_name).keys.index_by do |key|
      t(key, scope: [:activerecord, :enums, attr_name])
    end
  end

  def t_floor(number)
    if number.zero?
      t('helpers.floor.zero')
    elsif number == 1
      t('helpers.floor.one')
    elsif number > 1
      t('helpers.floor.positive', number: number)
    else
      t('helpers.floor.negative', number: - number)
    end
  end

  # build node
  def dt_col
    %w[col-sm-6 col-md-4 col-xl-2 col-print-full]
  end

  def dd_col
    %w[col-sm-6 col-md-8 col-xl-10 col-print-full]
  end

  def dt_dd_tag(term, &block)
    content_tag('div', class: 'row border-bottom mb-2 pb-2') do
      content_tag('dt', term, class: dt_col) +
        content_tag('dd', class: dd_col + ['mb-0'], &block)
    end
  end

  def dt_dd_for(recored, attr, **opts)
    if block_given?
      dt_dd_tag recored.class.human_attribute_name(attr) do
        yield recored.__send__(attr)
      end
    else
      dt_dd_for(recored, attr, opts) do |value|
        span_value_for(value, **opts)
      end
    end
  end

  def span_value_for(value, **opts)
    case value
    when nil
      content_tag('span', opts[:blank_alt] || t(:none, scope: :values), class: 'font-italic text-muted')
    when '', [], {}
      content_tag('span', opts[:blank_alt] || t(:empty, scope: :values), class: 'font-italic text-muted')
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
      content_tag('ul', class: 'list-inline mb-0') do
        list_html = sanitize('')
        value.each do |v|
          list_html += content_tag('li', class: 'list-inline-item border border-primary rounded px-1 mb-1') do
            span_value_for(v, **opts)
          end
        end
        list_html
      end
    when IPAddress
      if value.network?
        span_text_tag(value.to_string, **opts)
      else
        span_text_tag(value.to_s, **opts)
      end
    when ApplicationRecord
      link_to(value.to_s, value)
    else
      span_text_tag(value.to_s, **opts)
    end
  end

  def span_text_tag(value = nil, around: nil, **_, &block)
    if around.present?
      content_tag('span', around[0], class: 'text-muted') +
        content_tag('span', value, &block) +
        content_tag('span', around[1], class: 'text-muted')
    else
      content_tag('span', value, &block)
    end
  end

  def i_bool_tag(value)
    if value
      content_tag('i', '', class: 'far fa-check-square')
    else
      content_tag('i', '', class: 'far fa-square')
    end
  end

  def html_month(time)
    time.strftime('%Y-%m')
  end

  def html_date(time)
    time.strftime('%Y-%m-%d')
  end

  def html_time(time, second: true)
    if second
      time.strftime('%H:%M:%S')
    else
      time.strftime('%H:%M')
    end
  end

  def html_datetime_local(time, second: true)
    if second
      time.strftime('%Y-%m-%dT%H:%M:%S')
    else
      time.strftime('%Y-%m-%dT%H:%M')
    end
  end

  def html_datetime_zone(time)
    time.xmlschema
  end

  def badge(name, id: nil, level: :primary, enabled: true, hidden: false)
    return if hidden

    badge_classes = ['badge']
    if enabled
      badge_classes << "badge-#{level}"
    else
      badge_classes << 'badge-light' << 'text-muted'
    end
    content_tag('span', name, class: badge_classes, id: id)
  end

  def badge_boolean(model, attr, id: nil, level: :primary, disabled_show: false)
    enabled = model.__send__(attr)
    return if !disabled_show && !enabled

    name = model.class.human_attribute_name(attr)
    badge_classes = ['badge']
    if enabled
      badge_classes << "badge-#{level}"
    else
      badge_classes << 'badge-light' << 'text-muted'
    end
    content_tag('span', name, class: badge_classes, id: id)
  end
end
