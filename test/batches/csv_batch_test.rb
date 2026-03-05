require "test_helper"

class CsvBatchTest < ActiveSupport::TestCase
  setup do
    @processor = ApplicationProcessor.new
    @batch = CsvBatch.new(@processor)
  end

  test "gets_params_from_input" do
    input = StringIO.new <<~CSV
      id,string,boolean,none,number,list[],dict[key1],dict[key2],dict_list[][k1],dict_list[][k2],_other
      1,test1,true,!,42,a b,value1,value2,a1,a2,value
      2,,,,,,,,,,
    CSV
    @batch.open_input(input) do |desc|
      assert_equal({
        id: 1,
        string: "test1",
        boolean: "true",
        none: nil,
        number: "42",
        list: ["a", "b"],
        dict: {key1: "value1", key2: "value2"},
        dict_list: [
          {k1: "a1", k2: "a2"},
        ],
        _other: "value",
      }, @batch.gets_params(desc))
      assert_equal({id: 2}, @batch.gets_params(desc))
      assert_nil @batch.gets_params(desc)
    end
  end

  test "puts_params_to_output" do
    ApplicationProcessor.stub(:keys,
      [:string, :boolean, :none, :number, {list: [], dict: [:key1, :key2], dict_list: [[:k1, :k2]]}]) do
      output = StringIO.new
      @batch.open_output(output) do |desc|
        @batch.puts_params(desc, {
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
          _result: "value",
        })
      end
      assert_equal <<~CSV, output.string
        \u{feff}id,string,boolean,none,number,list[],dict[key1],dict[key2],dict_list[][k1],dict_list[][k2],_result,_message
        1,test1,true,,42,a b,value1,value2,a1,a2,value,
        1,test1,true,,42,a b,value1,value2,b1,b2,value,
      CSV
    end
  end
end
