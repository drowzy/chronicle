defmodule Chronicle.Slice.Log do
  alias Chronicle.Error

  @type t :: %__MODULE__{
          fd: Chronicle.Slice.fd(),
          fd_write: (Chronicle.Slice.fd(), iodata() -> :ok | {:error, term()}),
          filename: Path.t(),
          base_offset: integer(),
          size: integer(),
          max_size: integer()
        }
  defstruct [
    :fd,
    :fd_write,
    :filename,
    :base_offset,
    :size,
    :max_size
  ]

  @spec filename(offset :: integer() | String.t()) :: String.t()
  def filename(offset) when is_binary(offset) do
    offset <> ".log"
  end

  def filename(offset) do
    offset
    |> to_string()
    |> filename()
  end

  @spec new(Keyword.t()) :: t()
  def new(opts) do
    struct(__MODULE__, opts)
  end

  @spec fit?(t(), iodata()) :: boolean()
  def fit?(%__MODULE__{max_size: max_size, size: size}, binary) do
    max_size >= size + IO.iodata_length(binary)
  end

  @spec write(t(), iodata()) :: {:ok, t()} | {:error, term()}
  def write(%__MODULE__{fd: fd, fd_write: fd_write} = log, binary) do
    bin_size = IO.iodata_length(binary)

    with true <- fit?(log, binary),
         :ok <- fd_write.(fd, binary) do
      {:ok, %{log | size: log.size + bin_size}}
    else
      {:error, {:full, _ref}} ->
        reason = Error.enospc(bin_size, log.size, log.max_size)
        {:error, reason}

      false ->
        reason = Error.enospc(bin_size, log.size, log.max_size)
        {:error, reason}

      err ->
        err
    end
  end
end
