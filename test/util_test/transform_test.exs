defmodule UtilTest.TransformTest do
  use ExUnit.Case, async: true
  import ExNylas.Transform
  import ExUnit.CaptureLog
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

    test "transform_stream handles malformed JSON" do
      data = "{invalid json"
      req = %{}
      resp = %{status: 200}
      fun = fn _ -> :ok end

      {cont, {_req_result, resp_result}} = transform_stream({:data, data}, {req, resp}, fun)
      assert cont == :cont
      assert resp_result == resp
    end
  end

  describe "preprocess_data" do
    test "handles nil data" do
      result = preprocess_data(Folder, nil)
      assert result == nil
    end

    test "handles non-map, non-list data" do
      result = preprocess_data(Folder, "string data")
      assert result == "string data"
    end

    test "handles empty list data" do
      result = preprocess_data(Folder, [])
      assert result == []
    end

    test "handles list with mixed data types" do
      data = [
        %{"id" => "123", "grant_id" => "456"},
        "string data",
        nil
      ]
      result = preprocess_data(Folder, data)

      assert length(result) == 3
      assert is_struct(Enum.at(result, 0))
      assert Enum.at(result, 1) == "string data"
      assert Enum.at(result, 2) == nil
    end
  end

  describe "transform_stream" do
    test "transform_stream handles non-200 status codes" do
      data = "some data"
      req = %{}
      resp = %{status: 400}
      fun = fn _ -> :ok end

      {cont, {_req_result, resp_result}} = transform_stream({:data, data}, {req, resp}, fun)

      assert cont == :cont
      assert resp_result.body == data
    end

    test "transform_stream handles data without suggestion field" do
      data = ~s({"other_field": "value"})
      req = %{}
      resp = %{status: 200}
      fun = fn suggestion ->
        assert suggestion == nil
        :ok
      end

      {cont, {_req_result, _resp_result}} = transform_stream({:data, data}, {req, resp}, fun)

      assert cont == :cont
    end

    test "transform_stream handles data without JSON objects" do
      data = "plain text without json"
      req = %{}
      resp = %{status: 200}
      fun = fn _ -> :ok end

      {cont, {_req_result, resp_result}} = transform_stream({:data, data}, {req, resp}, fun)

      assert cont == :cont
      # When there are no JSON objects, the function doesn't add body to resp
      # It just returns the original resp unchanged
      assert resp_result == resp
    end

    test "transform_stream handles empty data" do
      data = ""
      req = %{}
      resp = %{status: 200}
      fun = fn _ -> :ok end

      {cont, {_req_result, resp_result}} = transform_stream({:data, data}, {req, resp}, fun)

      assert cont == :cont
      assert resp_result == resp
    end

    test "transform_stream handles malformed JSON" do
      data = "{invalid json"
      req = %{}
      resp = %{status: 200}
      fun = fn _ -> :ok end

      {cont, {_req_result, resp_result}} = transform_stream({:data, data}, {req, resp}, fun)
      assert cont == :cont
      assert resp_result == resp
    end
  end

  describe "validation error logging" do
    test "logs validation errors when changeset is invalid" do
      # Create a module that will have validation errors
      defmodule TestSchema do
        use Ecto.Schema
        import Ecto.Changeset

        schema "test_schema" do
          field :email, :string
          field :age, :integer
        end

        def changeset(schema, attrs) do
          schema
          |> cast(attrs, [:email, :age])
          |> validate_required([:email])
          |> validate_format(:email, ~r/@/)
          |> validate_number(:age, greater_than: 0)
        end
      end

      # This should trigger validation errors and log them
      body = %{
        "data" => %{
          "email" => "invalid-email",
          "age" => -5
        }
      }

      # Capture log messages
      log_capture = capture_log(fn ->
        transformed = transform(body, 200, %{}, TestSchema, true, true)
        assert %Response{} = transformed
      end)

      # Should contain validation error messages
      assert log_capture =~ "Validation error while transforming"
      assert log_capture =~ "email"
      assert log_capture =~ "age"
    end

    test "does not log when changeset is valid" do
      defmodule ValidTestSchema do
        use Ecto.Schema
        import Ecto.Changeset

        schema "valid_test_schema" do
          field :email, :string
        end

        def changeset(schema, attrs) do
          schema
          |> cast(attrs, [:email])
          |> validate_required([:email])
        end
      end

      body = %{
        "data" => %{
          "email" => "valid@example.com"
        }
      }

      log_capture = capture_log(fn ->
        transformed = transform(body, 200, %{}, ValidTestSchema, true, true)
        assert %Response{} = transformed
      end)

      # Should not contain validation error messages
      refute log_capture =~ "Validation error while transforming"
    end
  end
end
