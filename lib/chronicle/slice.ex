defmodule Chronicle.Slice do
  alias :disk_log, as: DiskLog
  alias Chronicle.Slice.{Log, Options}
  alias Chronicle.Error

  @type fd :: charlist()
  @type t :: %__MODULE__{}
  @type options :: [
          max_size: integer(),
          path: Path.t(),
          offset: integer(),
          fd_write: (term(), term() -> term())
        ]

  defstruct [
    :fd,
    :log,
    :index,
    :offset,
    :opts
  ]

  @spec open(options()) :: term()
  def open(opts) do
    opts = Options.sanitize(opts)
    dl_opts = Options.dlog_options(opts)

    with {:ok, fd} <- DiskLog.open(dl_opts) do
      log_opts = Options.log_options(opts, fd)
      log = Log.new(log_opts)

      {:ok,
       %__MODULE__{
         log: log,
         fd: fd,
         offset: opts.offset,
         opts: opts
       }}
    end
  end

  @spec write(t(), iodata()) :: {:ok, t()} | {:error, term()}
  def write(slice, bin) when is_binary(bin), do: write(slice, [bin])

  def write(%__MODULE__{log: log, offset: offset} = slice, bin) do
    case Log.write(log, bin) do
      {:ok, log} ->
        {:ok, %{slice | log: log, offset: offset + 1}}

      {:error, %Error{reason: {:enospc, _, _, _}}} ->
        slice
        |> rotate_log()
        |> write(bin)
    end
  end

  @spec rotate_log(t()) :: t()
  def rotate_log(%__MODULE__{opts: opts, offset: offset} = slice) do
    args = [
      offset: offset + 1,
      max_size: opts.max_size,
      path: opts.base_path
    ]

    with :ok <- close(slice),
         {:ok, slice} <- open(args) do
      slice
    end
  end

  @spec close(t()) :: :ok | {:error, term()}
  def close(%__MODULE__{fd: fd}) do
    DiskLog.close(fd)
  end
end
