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
        content_tag('dd', class: dt_col + ['mb-0'], &block)
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
      when :mail_body
        mail_body_tag(value, **opts)
      when :translate
        span_text_tag(t(value, scope: opts[:scope]), **opts)
      else
        span_text_tag(value, **opts)
      end
    when Time, Date, DateTime, ActiveSupport::TimeWithZone
      content_tag('span', l(value, format: opts[:format]))
    when true, false
      content_tag('div', class: 'custom-control custom-switch') do
        check_box_tag(:admin?, '1', value, disabled: true, class: 'custom-control-input') +
          label_tag(:admin?, '', class: 'custom-control-label')
      end
    when Enumerable
      content_tag('ul', class: 'list-inline mb-0') do
        list_html = sanitize('')
        value.each do |v|
          list_html += content_tag('li', class: 'list-inline-item border border-primary rounded px-1 mb-1') do
            span_value_for(v, **opts)
          end
        end
        list_html
      end
    when ApplicationRecord
      link_to(value.to_s, value)
    else
      content_tag('span', value.to_s, class: '')
    end
  end

  def mail_body_tag(value, **opts)
    content_tag('pre', value, class: 'border rounded mb-0 mail-body line-76-80') do
      span_text_tag(value, **opts)
    end
  end

  def span_text_tag(value, around: nil, **_)
    if around.present?
      content_tag('span', around[0], class: 'text-muted') +
        content_tag('span', value) +
        content_tag('span', around[1], class: 'text-muted')
    else
      content_tag('span', value)
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
end
