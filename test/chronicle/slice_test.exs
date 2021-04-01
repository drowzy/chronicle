defmodule Chronicle.SliceTest do
  use ExUnit.Case
  alias Chronicle.Slice

  describe "open/1" do
    setup do
      {:ok, slice} = Slice.open(path: "test", offset: 0)
      {:ok, slice: slice}
    end

    test "returns a new Slice handle with log, opts, fd set ", %{slice: slice} do
      offset = String.pad_leading("0", 22, "0")
      expected = String.to_charlist("test/#{offset}")
      assert %Slice.Log{} = slice.log
      assert %Slice.Options{} = slice.opts
      assert expected == slice.fd
    end
  end

  describe "write" do
    setup do
      tmp_path = tmp_dir!("test_write")
      File.mkdir_p!(tmp_path)

      on_exit(fn ->
        File.rm_rf!(tmp_path)
      end)

      {:ok, slice} = Slice.open(path: tmp_path, offset: 0, max_size: 6)
      {:ok, slice: slice, path: tmp_path}
    end

    test "tracks offset of writes in the log", %{slice: slice} do
      {:ok, slice} = Slice.write(slice, "bin")
      assert slice.offset == 1
    end

    test "should rotate to a new log once max_size is reached", %{slice: slice, path: path} do
      expected = "#{path}/#{String.pad_leading("3", 22, "0")}.log"

      slice =
        Enum.reduce(1..3, slice, fn _, acc ->
          {:ok, acc} = Slice.write(acc, "bin")
          acc
        end)

      assert slice.offset == 4
      assert File.exists?(expected)
    end
  end

  defp tmp_dir!(name) do
    tmp_dir = System.tmp_dir!()
    Path.join([tmp_dir, name])
  end
end
