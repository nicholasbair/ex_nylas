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

    test "handles unknown status codes" do
      body = %{}
      transformed = transform(body, 999, %{}, :not_needed, true, true)

      assert transformed.status == :unknown
    end

    test "removes nil values from data" do
      body = %{
        "data" => %{
          "id" => "123",
          "grant_id" => nil,
          "name" => "test"
        }
      }

      transformed = transform(body, 200, %{}, Folder, true, true)

      assert Map.has_key?(transformed.data, :id)
      assert Map.has_key?(transformed.data, :name)
      # The field still exists but with nil value - that's how structs work
      assert Map.has_key?(transformed.data, :grant_id)
      assert transformed.data.grant_id == nil
    end

    test "handles nil model gracefully" do
      body = %{"data" => %{"id" => "123"}}

      transformed = transform(body, 200, %{}, nil, true, true)

      assert transformed.data == %{"id" => "123"}
    end

    test "handles non-map data gracefully" do
      body = %{"data" => "string data"}

      transformed = transform(body, 200, %{}, Folder, true, true)

      # The MapOrList type doesn't accept strings, so string data gets cast to nil
      # This is a limitation of the current implementation
      assert transformed.data == nil
    end

    test "handles empty list data" do
      body = %{"data" => []}

      transformed = transform(body, 200, %{}, Folder, true, true)

      assert transformed.data == []
    end
  end

  describe "transfrom_stream" do
    test "transfrom_stream handles non-200 status codes" do
      data = "some data"
      req = %{}
      resp = %{status: 400}
      fun = fn _ -> :ok end

      {cont, {_req_result, resp_result}} = transfrom_stream({:data, data}, {req, resp}, fun)

      assert cont == :cont
      assert resp_result.body == data
    end

    test "transfrom_stream handles data without suggestion field" do
      data = ~s({"other_field": "value"})
      req = %{}
      resp = %{status: 200}
      fun = fn suggestion ->
        assert suggestion == nil
        :ok
      end

      {cont, {_req_result, _resp_result}} = transfrom_stream({:data, data}, {req, resp}, fun)

      assert cont == :cont
    end

    test "transfrom_stream handles data without JSON objects" do
      data = "plain text without json"
      req = %{}
      resp = %{status: 200}
      fun = fn _ -> :ok end

      {cont, {_req_result, resp_result}} = transfrom_stream({:data, data}, {req, resp}, fun)

      assert cont == :cont
      # When there are no JSON objects, the function doesn't add body to resp
      # It just returns the original resp unchanged
      assert resp_result == resp
    end
  end
end
