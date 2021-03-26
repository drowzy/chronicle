defmodule Chronicle.Error do
  @type t :: %__MODULE__{}
  @type reason :: {:enospc, bin_size :: integer(), file_size :: integer(), max_size :: integer()}

  defexception [:reason]

  @spec message(t()) :: String.t()
  def message(%__MODULE__{reason: reason}) do
    format_reason(reason)
  end

  @spec enospc(integer(), integer(), integer()) :: t()
  def enospc(bin_size, file_size, max_size) do
    %__MODULE__{reason: {:enospc, bin_size, file_size, max_size}}
  end

  def format_reason({:enospc, bin_size, file_size, max_size}) do
    "Unable to write iodata bin_size=#{bin_size} size=#{file_size} max_size=#{max_size}"
  end
end
