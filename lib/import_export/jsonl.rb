require "fileutils"
require "logger"

require "import_export/batch"

module ImportExport
  class Jsonl < Batch
    content_type "application/jsonl"
    extname ".jsonl"

    attr_reader :result, :count
  end
end
