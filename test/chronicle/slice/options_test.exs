defmodule Chronicle.Slice.OptionsTest do
  use ExUnit.Case
  alias Chronicle.Slice.Options

  describe "sanitize/1" do
    test "raises if there's missing options" do
      assert_raise ArgumentError, fn ->
        Options.sanitize([])
      end
    end

    test "returns an Options struct if valid with default opts" do
      assert %Options{} = o = Options.sanitize(path: "/var/log", offset: 0)

      assert o.path == "/var/log/0"
      assert o.filename == "/var/log/0.log"
      assert o.idx_filename == "/var/log/0.idx"
      assert o.max_size > 0
      assert o.size == 0
    end
  end
end
