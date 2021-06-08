# config/initializers/attribute_normalizer.rb
AttributeNormalizer.configure do |config|
  config.normalizers[:downcase] = lambda do |value, _options|
    value.is_a?(String) ? value.downcase : value
  end

  config.normalizers[:upcase] = lambda do |value, _options|
    value.is_a?(String) ? value.upcase : value
  end

  config.normalizers[:sanitize] = lambda do |value, options|
    config = options[:config] || Sanitize::Config::RELAXED
    value.is_a?(String) ? Sanitize.fragment(value, config) : value
  end
end
