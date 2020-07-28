defmodule Avatar do
  @moduledoc """
  Main module to generate avatars and save them to disk.

  The input string is hashed and the first three bytes
  of the hash are used to determine the base color.

  The module generates a `:pixels` value which represents
  the hash of the input string.
  """
  defstruct ~w[input hash color pixels image config]a

  @default_config [
    monochrome: false,
    size: 11,
    pixel_size: 30,
    type: Avatar.Squares
  ]

  @doc """
  Generates a new Avatar based on the input binary and the passed config Keyword list.

  `config`
    * `:monochrome` - when set to `true` the generated image will only use one color.
    Default is `false`
    * `:size` - how many columns & rows the avatar will have. Default is 11
    * `:pixel_size` - size in pixelsof the individual blocks that make up the generated
    image. Default is `30`
    * `:type` - Module name of the image generator. Currently only supports Squares.
    Default is `Avatar.Squares`
  """
  def new(input, config \\ []) do
    input
    |> init(config)
    |> put_hash()
    |> put_color()
    |> put_pixels()
    |> build_image()
  end

  @doc """
  Save the generated avatar image to disk.

  The default path is the current working directory, using the input binary as the filename.
  """
  def save(%Avatar{} = avatar) do
    save(avatar, "#{avatar.input}.png")
  end

  @doc """
  Save the generated avatar image to disk.
  """
  def save(%Avatar{} = avatar, path) do
    File.write(path, avatar.image)
  end

  def init(input_string, config) do
    config = default_config(config)

    %__MODULE__{input: input_string, config: config}
  end

  def default_config(config) do
    @default_config
    |> Keyword.merge(config)
    |> calculate_size()
  end

  def calculate_size(config) do
    Keyword.merge(
      config,
      rows: config[:size],
      columns: ceil(config[:size] / 2)
    )
  end

  def put_hash(%{input: input} = avatar) do
    %{avatar | hash: :crypto.hash(:sha512, input)}
  end

  def put_color(%{hash: <<r, g, b, _rest::binary>>} = avatar) do
    %{avatar | color: :egd.color({r, g, b})}
  end

  def put_pixels(%{hash: <<_r, _g, _b, pixels::binary>>} = avatar) do
    pixel_map =
      for <<pixel::1 <- pixels>> do
        pixel == 1
      end
      |> Enum.with_index()

    %{avatar | pixels: pixel_map}
  end

  def build_image(%{config: config} = avatar) do
    config[:type].build_image(avatar)
  end
end
