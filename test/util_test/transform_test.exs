defmodule UtilTest.TransformTest do
  use ExUnit.Case, async: true
  import ExNylas.Transform
  alias ExNylas.{
    Response,
    Folder,
    HostedAuthentication.Grant
  }

  describe "transform" do
    test "transform transforms into the common response struct if common is true" do
      body = %{}
      transformed = transform(body, 200, %{}, :not_needed, true, true)

      assert %Response{} = transformed
      assert transformed.status == :ok
    end

    test "transform transforms into the common response struct with the child struct" do
      body = %{
        "data" => %{
          "id" => "123",
          "grant_id" => "456"
        }
      }

      transformed = transform(body, 200, %{}, Folder, true, true)

      assert %Response{} = transformed
      assert Map.get(transformed.data, :__struct__) == Folder
    end

    test "transform transforms into the common response struct with the list of child structs" do
      body = %{
        "data" => [
          %{
            "id" => "123",
            "grant_id" => "456"
          }
        ]
      }

      transformed = transform(body, 200, %{}, Folder, true, true)

      assert %Response{} = transformed
      assert [%Folder{}] = transformed.data
    end

    test "transform transforms into the provided struct if common is false" do
      body = %{
        "id" => "123",
        "grant_id" => "456"
      }

      transformed = transform(body, 200, %{}, Grant, false, true)

      assert %Grant{} = transformed
    end

    test "transform does not transform the body if transform is false" do
      body = %{
        "id" => "123",
        "grant_id" => "456"
      }

      transformed = transform(body, 200, %{}, :not_needed, true, false)

      assert transformed == body
    end

    test "transforms into the common response struct with headers" do
      body = %{}
      headers = %{"x-request-id" => "123"}
      transformed = transform(body, 200, headers, :not_needed, true, true)

      assert transformed.headers == headers
    end

    test "includes headers in response when transforming with data" do
      body = %{
        "data" => %{
          "id" => "123",
          "grant_id" => "456"
        }
      }
      headers = %{"x-request-id" => "123", "content-type" => "application/json"}
      transformed = transform(body, 200, headers, Folder, true, true)

      assert transformed.headers == headers
      assert Map.get(transformed.data, :__struct__) == Folder
    end

    test "handles string body with headers in preprocess_body" do
      body = ~s({"data": {"id": "123"}})
      headers = %{"x-request-id" => "123"}
      transformed = transform(body, 200, headers, Folder, true, true)

      assert transformed.headers == headers
      assert transformed.status == :ok
    end
  end
end
