require "test_helper"

class YamlBatchTest < ActiveSupport::TestCase
  setup do
    @processor = Minitest::Mock.new
    @batch = YamlBatch.new(@processor)
  end

  test "gets_params_from_input" do
    input = StringIO.new <<~YAML
      - id: 1
        string: test1
        boolean: true
        none: null
        number: 42
        list:
        - a
        - b
        dict:
          key1: value1
          key2: value2
        dict_list:
        - k1: a1
          k2: a2
        - k1: b1
          k2: b2
        _other: value
      - id: 2
    YAML
    @batch.open_input(input) do |desc|
      assert_equal({
        id: 1,
        string: "test1",
        boolean: true,
        none: nil,
        number: 42,
        list: ["a", "b"],
        dict: {key1: "value1", key2: "value2"},
        dict_list: [
          {k1: "a1", k2: "a2"},
          {k1: "b1", k2: "b2"},
        ],
        _other: "value",
      }, @batch.gets_params(desc))
      assert_equal({id: 2}, @batch.gets_params(desc))
      assert_nil @batch.gets_params(desc)
    end
  end

  # test "puts_params_to_output" do
  #   assert_not @node_processor.has_privilege?
  # end
end
