defmodule UtilTest.TransformTest do
  use ExUnit.Case, async: true
  import ExNylas.Transform
  alias ExNylas.{
    Response,
    Folder,
    HostedAuthentication.Grant
  }

  describe "transform" do
    test "transforms into the common response struct if common is true" do
      body = %{}
      transformed = transform(body, 200, :not_needed, true, true)

      assert Map.get(transformed, :__struct__) == Response
    end

    test "transforms into the common response struct with the child struct" do
      body = %{
        "data" => %{
          "id" => "123",
          "grant_id" => "456"
        }
      }
      transformed = transform(body, 200, Folder, true, true)

      assert Map.get(transformed.data, :__struct__) == Folder
    end

    test "transforms into the common response struct with the list of child structs" do
      body = %{
        "data" => [
          %{
            "id" => "123",
            "grant_id" => "456"
          },
          %{
            "id" => "456",
            "grant_id" => "789"
          }
        ]
      }
      transformed = transform(body, 200, Folder, true, true)

      assert List.first(transformed.data) |>  Map.get(:__struct__) == Folder
      assert length(transformed.data) == 2
    end

    test "transforms into the provided struct if common is false" do
      body = %{
        "grant_id" => "456",
        "provider" => "google",
        "email" => "abc@example.com"
      }
      transformed = transform(body, 200, Grant, false, true)

      assert Map.get(transformed, :__struct__) == Grant
    end

    test "does not transform the body if transform is false" do
      body = "raw"
      transformed = transform(body, 200, :not_needed, true, false)

      assert body == transformed
    end
  end
end
