require "test_helper"

class JsonlBatchTest < ActiveSupport::TestCase
  setup do
    @processor = ApplicationProcessor.new
    @batch = JsonlBatch.new(@processor)
  end

  test "gets_params_from_input" do
    input = StringIO.new <<~JSONL
        {"id":1,"string":"test1","boolean":true,"number":42,"list":["a","b"],"dict":{"key1":"value1","key2":"value2"},"dict_list":[{"k1":"a1","k2":"a2"},{"k1":"b1","k2":"b2"}],"_result":"value"}
        {"id":2,"string":"","boolean":false,"number":null,"list":[],"dict":{"key1":null,"key2":null},"dict_list":[{"k1":null,"k2":null}],"_result":null}
        {"id":3}
        {"id":4,"_destroy":true}
        {"string":"new"}
      JSONL
    @batch.open_input(input) do |desc|
      assert_equal({
        id: 1,
        string: "test1",
        boolean: true,
        number: 42,
        list: ["a", "b"],
        dict: {key1: "value1", key2: "value2"},
        dict_list: [
          {k1: "a1", k2: "a2"},
          {k1: "b1", k2: "b2"},
        ],
        _result: "value",
      }, @batch.gets_params(desc))
      assert_equal({
        id: 2,
        string: "",
        boolean: false,
        number: nil,
        list: [],
        dict: {key1: nil, key2: nil},
        dict_list: [
          {k1: nil, k2: nil},
        ],
        _result: nil,
      }, @batch.gets_params(desc))
      assert_equal({id: 3}, @batch.gets_params(desc))
      assert_equal({id: 4, _destroy: true}, @batch.gets_params(desc))
      assert_equal({string: "new"}, @batch.gets_params(desc))
      assert_nil @batch.gets_params(desc)
    end
  end

  test "puts_params_to_output" do
    ApplicationProcessor.stub(:keys,
      [:string, :boolean, :number, {list: [], dict: [:key1, :key2], dict_list: [[:k1, :k2]]}]) do
      output = StringIO.new
      @batch.open_output(output) do |desc|
        @batch.puts_params(desc, {
          id: 1,
          string: "test1",
          boolean: true,
          number: 42,
          list: ["a", "b"],
          dict: {key1: "value1", key2: "value2"},
          dict_list: [
            {k1: "a1", k2: "a2"},
            {k1: "b1", k2: "b2"},
          ],
          _result: "value",
        })
        @batch.puts_params(desc, {
          id: 2,
          string: "",
          boolean: false,
          number: nil,
          list: [],
          dict: {},
          dict_list: [{}],
          _result: nil,
        })
        @batch.puts_params(desc, {id: 3})
      end
      assert_equal <<~JSONL, output.string
        {"id":1,"string":"test1","boolean":true,"number":42,"list":["a","b"],"dict":{"key1":"value1","key2":"value2"},"dict_list":[{"k1":"a1","k2":"a2"},{"k1":"b1","k2":"b2"}],"_result":"value"}
        {"id":2,"string":"","boolean":false,"number":null,"list":[],"dict":{},"dict_list":[{}],"_result":null}
        {"id":3}
      JSONL
    end
  end
end
