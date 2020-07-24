defmodule Avatar do
  defstruct ~w[input hash color pixels image config]a

  @default_config [
    monochrome: false,
    size: 11,
    pixel_size: 30,
    type: Avatar.Squares
  ]

  def new(input, config \\ []) do
    input
    |> init(config)
    |> put_hash()
    |> put_color()
    |> put_pixels()
    |> build_rows()
    |> build_image()
  end

  def save(avatar) do
    :egd.save(avatar.image, "#{avatar.input}.png")
  end

  def init(input_string, config) do
    config = Keyword.merge(@default_config, config)

    config = calculate_size(config)

    %__MODULE__{input: input_string, config: config}
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
      |> Enum.take(avatar.config[:columns] * avatar.config[:rows])

    %{avatar | pixels: pixel_map}
  end

  def build_rows(%{pixels: pixels} = avatar) do
    with_pixel =
      for {true, index} <- Enum.with_index(pixels) do
        index
      end

    %{avatar | pixels: with_pixel}
  end

  def build_image(%{config: config} = avatar) do
    config[:type].build_image(avatar)
  end
end
