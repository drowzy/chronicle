defmodule Chronicle.Slice.LogTest do
  use ExUnit.Case
  alias Chronicle.Slice.Log

  test "filename/1 returns the log filename" do
    assert "log.log" == Log.filename("log")
  end

  test "fit?/2 returns true if the provided iodata fits in current log" do
    log = %Log{max_size: 10, size: 0}

    assert Log.fit?(log, Enum.map(0..5, &inspect/1))
    refute Log.fit?(log, Enum.map(0..10, &inspect/1))
  end

  test "write/2 increments the size of iodata length if the write was successful" do
    log = %Log{max_size: 10, size: 0, fd_write: fn _, _ -> :ok end}
    assert {:ok, log} = Log.write(log, Enum.map(0..5, &inspect/1))

    assert log.size == 6
  end

  test "write/2 returns an error if the buffer does not fit inside the file" do
    log = %Log{max_size: 10, size: 10, fd_write: fn _, _ -> :ok end}

    assert {:error, %Chronicle.Error{reason: {reason_code, _, _, _}}} =
             Log.write(log, Enum.map(0..5, &inspect/1))

    assert reason_code == :enospc
  end
end
