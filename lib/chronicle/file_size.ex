defmodule Chronicle.FileSize do
  @spec mb(integer()) :: integer()
  def mb(num_mb) do
    num_mb * trunc(:math.pow(10, 6))
  end

  @spec kb(integer()) :: integer()
  def kb(num_kb) do
    num_kb * trunc(:math.pow(10, 3))
  end

  @spec from_file(Path.t()) :: integer()
  def from_file(path) do
    case File.stat(path) do
      {:ok, %File.Stat{size: size}} -> size
      {:error, _posix} -> 0
    end
  end
end
