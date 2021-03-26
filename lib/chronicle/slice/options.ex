defmodule Chronicle.Slice.Options do
  alias Chronicle.FileSize
  @type t :: %__MODULE__{}

  @required [:path, :offset]
  @default_opts [
    max_size: FileSize.mb(1),
    fd_write: &:disk_log.blog_terms/2
  ]

  @enforce_keys [
    :max_size,
    :path,
    :offset,
    :filename,
    :size,
    :fd_write
  ]

  defstruct [
    :max_size,
    :base_path,
    :path,
    :offset,
    :filename,
    :idx_filename,
    :size,
    :fd_write
  ]

  def new(opts) do
    file_base =
      opts
      |> Keyword.fetch!(:offset)
      |> to_string()

    base_path = Keyword.fetch!(opts, :path)
    path = Path.join([base_path, file_base])

    idx = filename(path, ".idx")
    log = filename(path, ".log")

    opts =
      opts ++
        [
          base_path: base_path,
          idx_filename: idx,
          filename: log,
          path: path,
          size: FileSize.from_file(log)
        ]

    struct(__MODULE__, opts)
  end

  def sanitize(opts) do
    @default_opts
    |> Keyword.merge(opts)
    |> validate_required()
    |> new()
  end

  @spec log_options(t(), term()) :: Keyword.t()
  def log_options(opts, fd) do
    opts
    |> Map.from_struct()
    |> Map.put(:fd, fd)
    |> Map.take([
      :fd,
      :filename,
      :max_size,
      :size,
      :fd_write
    ])
    |> Enum.into([])
  end

  @spec dlog_options(t()) :: Keyword.t()
  def dlog_options(opts) do
    name = opts |> Map.get(:path) |> String.to_charlist()
    file = opts |> Map.get(:filename) |> String.to_charlist()
    size = opts |> Map.get(:max_size) |> trunc()

    [
      name: name,
      file: file,
      size: size,
      format: :external,
      head: :none,
      type: :halt
    ]
  end

  defp validate_required(opts) do
    Enum.each(@required, fn key ->
      unless Keyword.has_key?(opts, key) do
        raise ArgumentError, message: "option: #{inspect(key)} is required"
      end
    end)

    opts
  end

  defp filename(offset, ext) when is_binary(offset) do
    offset <> ext
  end
end
