defmodule Chronicle.Slice do
  alias :disk_log, as: DiskLog
  alias Chronicle.Slice.{Log, Options}
  alias Chronicle.Error

  @type fd :: charlist()
  @type t :: %__MODULE__{}
  defstruct [
    :fd,
    :log,
    :index,
    :opts
  ]

  @spec open(Keyword.t()) :: term()
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
         opts: opts
       }}
    end
  end

  @spec write(t(), iodata()) :: {:ok, t()} | {:error, term()}
  def write(%__MODULE__{log: log} = slice, bin) do
    case Log.write(log, bin) do
      {:ok, log} ->
        {:ok, %{slice | log: log}}

      {:error, %Error{reason: {:nospace, _, _, _}}} ->
        slice
        |> rotate_log()
        |> write(bin)
    end
  end

  @spec rotate_log(t()) :: t()
  def rotate_log(%__MODULE__{opts: opts} = slice) do
    args = [
      offset: opts.offset + 1,
      size: opts.max_size,
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
