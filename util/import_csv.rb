require 'csv'
require 'fileutils'
require 'logger'

class ImportCSV
  def initialize(logger = Logger.new($stderr))
    @logger = logger
  end

  def run(args)
    csv_file = args[0]
    if csv_file.nil?
      warn "USAGE: rails runner #{$0} CSV_FILE"
      exit(1)
    end
    import(csv_file)
  end

  def import(csv_file)
    results = {
      'success' => 0,
      'failure' => 0,
      'error' => 0,
      'skip' => 0,
    }

    backup_file = "#{csv_file}.#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}"
    tmp_file = "#{csv_file}.tmp"
  
    csv_datas = CSV.read(csv_file, encoding: 'BOM|UTF-8', headers: :first_row)
  
    File.open(tmp_file, 'wb:UTF-8') do |io|
      io.write "\u{feff}"
      io.puts csv_datas.headers.to_csv
      count = 0
      csv_datas.each do |data|
        count += 1

        data['result'] = ''
        data['message'] = ''

        do_action(data)
      rescue StandardError => e
        data['result'] = "error"
        data['message'] = e.message
      ensure
        @logger.info(
          "#{count}: [#{data['result']}] #{data['id']}: #{data['message']}")
        results[data['result']] += 1
        io.puts data.to_csv
      end
    end
    @logger.info("RESULTS: #{results.to_json}")

    FileUtils.move(csv_file, backup_file)
    FileUtils.move(tmp_file, csv_file)

    results
  end

  def do_action(data)
    if data['action'].blank?
      data['result'] = 'skip'
      return
    end

    case data['action'].first.upcase
    when 'C'
      success, model = create(data)
    when 'R'
      success, model = read(data)
    when 'U'
      success, model = update(data)
    when 'D'
      success, model = delete(data)
    else
      raise "unknown action: #{data['action']}"
    end
    if success
      data['id'] = model.id
      data['action'] = ''
      data['result'] = 'success'
    else
      data['result'] = 'failure'
      data['message'] = model.errors.to_json
    end
  end

  def create(data)
    raise NotImplementedError
  end
  
  def reade(data)
    raise NotImplementedError
  end

  def update(data)
    raise NotImplementedError
  end

  def delete(data)
    raise NotImplementedError
  end
end

if $0 == __FILE__
  ic = ImportCSV.new
  ic.run(ARGV)
end
