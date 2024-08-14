defmodule ExNylasTest do
  use ExUnit.Case

  defmodule MockModule do
    use ExNylas,
      object: "messages",
      struct: ExNylas.Message,
      readable_name: "message",
      include: [:all, :build, :create, :delete, :find, :first, :list, :update]
  end

  test "all function is generated" do
    assert function_exported?(MockModule, :all, 2)
  end

  test "all! function is generated" do
    assert function_exported?(MockModule, :all!, 2)
  end

  test "build function is generated" do
    assert function_exported?(MockModule, :build, 1)
  end

  test "build! function is generated" do
    assert function_exported?(MockModule, :build!, 1)
  end

  test "create function is generated" do
    assert function_exported?(MockModule, :create, 3)
  end

  test "create! function is generated" do
    assert function_exported?(MockModule, :create!, 3)
  end

  test "delete function is generated" do
    assert function_exported?(MockModule, :delete, 3)
  end

  test "delete! function is generated" do
    assert function_exported?(MockModule, :delete!, 3)
  end

  test "find function is generated" do
    assert function_exported?(MockModule, :find, 3)
  end

  test "find! function is generated" do
    assert function_exported?(MockModule, :find!, 3)
  end

  test "first function is generated" do
    assert function_exported?(MockModule, :first, 2)
  end

  test "first! function is generated" do
    assert function_exported?(MockModule, :first!, 2)
  end

  test "list function is generated" do
    assert function_exported?(MockModule, :list, 2)
  end

  test "list! function is generated" do
    assert function_exported?(MockModule, :list!, 2)
  end

  test "update function is generated" do
    assert function_exported?(MockModule, :update, 4)
  end

  test "update! function is generated" do
    assert function_exported?(MockModule, :update!, 4)
  end
end
