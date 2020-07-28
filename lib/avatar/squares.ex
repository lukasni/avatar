defmodule Avatar.Squares do
  @moduledoc """
  Generates identicons similar to Github-style identicons.

  Each Pixel is a flat colour square, the generated image is
  mirrored along the center row for odd sizes, between the
  center two rows for even sizes.
  """
  def build_image(%Avatar{} = avatar) do
    img = scene(avatar.config)

    # use the 3rd, 4th and 5th byte of the hash as the RNG seed.
    <<_, _, _, a, b, c, _::binary>> = avatar.hash
    :rand.seed(:exsplus, {a, b, c})

    pixels =
      avatar.pixels
      |> Enum.take(avatar.config[:columns] * avatar.config[:rows])

    for {true, index} <- pixels do
      color =
        if avatar.config[:monochrome] do
          avatar.color
        else
          maybe_shift_color(avatar.color)
        end

      {p1, p2} = pixel_for_index(index, avatar.config)
      {m1, m2} = mirror_for_index(index, avatar.config)
      :egd.filledRectangle(img, p1, p2, color)
      :egd.filledRectangle(img, m1, m2, color)
    end

    %{avatar | image: :egd.render(img)}
  end

  def pixel_for_index(index, config) do
    origin_x = col_for_index(index, config) * config[:pixel_size]
    origin_y = row_for_index(index, config) * config[:pixel_size]
    {{origin_x, origin_y}, {origin_x + config[:pixel_size], origin_y + config[:pixel_size]}}
  end

  def mirror_for_index(index, config) do
    origin_x = (config[:rows] - 1 - col_for_index(index, config)) * config[:pixel_size]
    origin_y = row_for_index(index, config) * config[:pixel_size]

    {{origin_x, origin_y}, {origin_x + config[:pixel_size], origin_y + config[:pixel_size]}}
  end

  def row_for_index(index, config) do
    div(index, config[:columns])
  end

  def col_for_index(index, config) do
    rem(index, config[:columns])
  end

  def scene(config) do
    :egd.create(
      config[:pixel_size] * config[:rows],
      config[:pixel_size] * config[:rows]
    )
  end

  def maybe_shift_color({r, g, b, a}) do
    case :rand.uniform(3) do
      1 ->
        case :rand.uniform(2) do
          1 ->
            shift_up({r, g, b, a})

          2 ->
            shift_down({r, g, b, a})
        end

      _ ->
        {r, g, b, a}
    end
  end

  def shift_up({r, g, b, a}) do
    {
      shift_up(r),
      shift_up(g),
      shift_up(b),
      a
    }
  end

  def shift_up(x) do
    min(1, x * 1.1)
  end

  def shift_down({r, g, b, a}) do
    {
      shift_down(r),
      shift_down(g),
      shift_down(b),
      a
    }
  end

  def shift_down(x) do
    max(0, x * 0.9)
  end
end
