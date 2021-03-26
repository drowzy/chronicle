defmodule Chronicle.SliceTest do
  use ExUnit.Case
  alias Chronicle.Slice

  describe "open/1" do
    setup do
      {:ok, slice} = Slice.open(path: "test", offset: 0)
      {:ok, slice: slice}
    end

    test "returns a new Slice handle", %{slice: slice} do
    end
  end
end
