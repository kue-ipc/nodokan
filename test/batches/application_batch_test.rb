require "test_helper"
require "stringio"

class ApplicationBatchTest < ActiveSupport::TestCase
  setup do
    @processor = NodesProcessor.new
    @batch = Class.new(ApplicationBatch) do
      def open_input(input)
        yield input
      end

      def gets_params(desc)
        desc.shift
      end

      def open_output(output)
        yield output
      end

      def puts_params(desc, params)
        desc << params
      end
    end.new(@processor)
  end

  test "load and run" do
    input = [
      {id: nodes(:node).id},
      {id: nodes(:desktop), name: "test"},
      {name: "hoge"},
      {id: nodes(:note), _destroy: true},
    ]
    @batch.load(input)
    output = []
    @batch.run(output)

    assert_equal nodes(:node).name, output[0][:name]
  end

  test "error load and run with invalid input" do
    input = [{id: 1, hoge: "fuga"}]
    assert_raises ApplicationBatch::InvalidInputError do
      @batch.load(input)
    end
  end

  test "load_ids and run" do
    @batch.load_ids
    output = []
    @batch.run(output)

    assert_equal Node.count, output.size
  end
end
