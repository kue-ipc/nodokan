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
    input = [{id: 1}, {id: 2, name: "test"}, {name: "hoge"}, {id: 3, _destroy: true}]
    @batch.load(input)
    output = []
    @batch.run(output)

    # assert_equal input, output
  end

  test "error load and run" do
    input = [{id: 1, hoge: "fuga"}]
    assert_raises(ApplicationBatch::InvalidParamsError) do
      @batch.load(input)
    end

    # assert_equal input, output
  end
end
