defmodule Avatar.SquaresTest do
  use ExUnit.Case
  doctest Avatar

  alias Avatar.Squares

  test "shifting hue stays within bounds" do
    assert Squares.shift_up(0.99) <= 1.0
    assert Squares.shift_down(0.01) >= 0.0

    match?(
      {r, g, b, _} when r <= 1 and g <= 1 and b <= 1,
      Squares.shift_up({0.99, 0.99, 0.99, 1})
    )

    match?(
      {r, g, b, _} when r >= 0 and g >= 0 and b >= 0,
      Squares.shift_down({0.01, 0.01, 0.01, 1})
    )
  end

  test "shifting hues doesn't change alpha" do
    assert {_, _, _, 1} = Squares.shift_down({0.5, 0.5, 0.5, 1})
    assert {_, _, _, 0.5} = Squares.shift_up({0.5, 0.5, 0.5, 0.5})
  end

  test "correct column for index based on configured columns" do
    config = %{columns: 3}

    assert 0 = Squares.col_for_index(0, config)
    assert 1 = Squares.col_for_index(1, config)
    assert 2 = Squares.col_for_index(2, config)
    assert 0 = Squares.col_for_index(3, config)
  end

  test "correct row for index based on configured columns" do
    config = %{columns: 3}

    assert 0 = Squares.row_for_index(0, config)
    assert 0 = Squares.row_for_index(1, config)
    assert 0 = Squares.row_for_index(2, config)
    assert 1 = Squares.row_for_index(3, config)
  end

  test "pixel_for_index returns coordinates of top left and bottom right corner" do
    config = %{columns: 3, pixel_size: 10}

    assert {{0, 0}, {10, 10}} = Squares.pixel_for_index(0, config)
    assert {{0, 10}, {10, 20}} = Squares.pixel_for_index(3, config)
    assert {{10, 10}, {20, 20}} = Squares.pixel_for_index(4, config)
  end

  test "mirror_for_index returns coordinates of the mirrored pixel" do
    config = %{columns: 3, rows: 6, pixel_size: 10}

    assert {{50, 0}, {60, 10}} = Squares.mirror_for_index(0, config)
    assert {{40, 0}, {50, 10}} = Squares.mirror_for_index(1, config)
    assert {{50, 10}, {60, 20}} = Squares.mirror_for_index(3, config)
  end
end
