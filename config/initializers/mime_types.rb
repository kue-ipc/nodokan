# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# yaml
if (yaml_mime_type = Mime::Type.lookup_by_extension(:yaml).nil?)
  Mime::Type.unregister(yaml_mime_type.symbol)
end
Mime::Type.register "application/yaml", :yaml, %w[application/x-yaml text/yaml text/x-yaml], %w[yml yaml]
Marcel::MimeType.extend "application/yaml", extensions: %w[yml yaml],  parents: "text/x-yaml"

# jsonl
Mime::Type.register "application/jsonl", :jsonl, [], %w[jsonl]
Marcel::MimeType.extend "application/jsonl", extensions: %w[jsonl]
