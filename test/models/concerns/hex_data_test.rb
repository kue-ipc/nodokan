require "test_helper"

class HexDataTest < ActiveSupport::TestCase
  setup do
    @class = Class.new do
      include HexData
    end
    @data = String.new("\x00\x7f\x80\xff", encoding: Encoding::ASCII_8BIT)
    @str = "00-7F-80-FF"
    @list = [0, 127, 128, 255]
  end

  test "hex_data_to_list" do
    assert_equal @list, @class.hex_data_to_list(@data)

    assert_empty @class.hex_data_to_list(String.new)
    assert_nil @class.hex_data_to_list(nil)
  end

  test "hex_list_to_data" do
    assert_equal @data, @class.hex_list_to_data(@list)
    # 超えた場合は8bitしかみない
    assert_equal @data, @class.hex_list_to_data([256, 127, 128, -1])

    assert_empty @class.hex_list_to_data([])
    assert_nil @class.hex_list_to_data(nil)
  end

  test "hex_data_to_str" do
    assert_equal @str, @class.hex_data_to_str(@data)
    assert_equal @str.downcase, @class.hex_data_to_str(@data, char_case: :lower)
    assert_equal @str.tr("-", ":"), @class.hex_data_to_str(@data, sep: ":")
    assert_equal @str.downcase.delete("-"),
      @class.hex_data_to_str(@data, char_case: :lower, sep: "")

    assert_empty @class.hex_data_to_str(String.new)
    assert_nil @class.hex_data_to_str(nil)
  end

  test "hex_str_to_data" do
    assert_equal @data, @class.hex_str_to_data(@str)
    assert_raises(ArgumentError) do
      @class.hex_str_to_data(@str, igonre_chars: "")
    end
    assert_raises(ArgumentError) do
      @class.hex_str_to_data("#{@str}X")
    end
    assert_raises(ArgumentError) do
      @class.hex_str_to_data(@str[1..])
    end

    assert_empty @class.hex_str_to_data("")
    assert_nil @class.hex_str_to_data(nil)
  end

  test "hex_list_to_str" do
    assert_equal @str, @class.hex_list_to_str(@list)
    assert_equal @str.downcase, @class.hex_list_to_str(@list, char_case: :lower)
    assert_equal @str.tr("-", ":"), @class.hex_list_to_str(@list, sep: ":")
    assert_equal @str.downcase.delete("-"),
      @class.hex_list_to_str(@list, char_case: :lower, sep: "")

    assert_empty @class.hex_list_to_str([])
    assert_nil @class.hex_list_to_str(nil)
  end

  test "hex_str_to_list" do
    assert_equal @list, @class.hex_str_to_list(@str)
    assert_raises(ArgumentError) do
      @class.hex_str_to_list(@str, igonre_chars: "")
    end
    assert_raises(ArgumentError) do
      @class.hex_str_to_list("#{@str}X")
    end
    assert_raises(ArgumentError) do
      @class.hex_str_to_list(@str[1..])
    end

    assert_empty @class.hex_str_to_list("")
    assert_nil @class.hex_str_to_list(nil)
  end
end
