defmodule Chronicle.SliceTest do
  use ExUnit.Case
  alias Chronicle.Slice

  describe "open/1" do
    setup do
      {:ok, slice} = Slice.open(path: "test", offset: 0)
      {:ok, slice: slice}
    end

    test "returns a new Slice handle with log, opts, fd set ", %{slice: slice} do
      assert %Slice.Log{} = slice.log
      assert %Slice.Options{} = slice.opts
      assert 'test/0' = slice.fd
    end
  end
end
