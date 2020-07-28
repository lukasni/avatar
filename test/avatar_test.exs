defmodule AvatarTest do
  use ExUnit.Case
  doctest Avatar

  test "running Avatar.new creates a struct with a binary representation of the image" do
    avatar = Avatar.new("test")

    assert %Avatar{input: "test"} = avatar
    assert match?(%{image: image} when is_binary(image), avatar)
  end

  test "multiple runs produce same result" do
    a1 = Avatar.new("test")
    a2 = Avatar.new("test")

    assert a1 == a2
    assert a1.image == a2.image
  end
end
