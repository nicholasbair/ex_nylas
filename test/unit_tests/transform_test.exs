defmodule ExNylas.TransformTest do
  use ExUnit.Case, async: true
  alias ExNylas.{Transform, Response, DecodeError}

  describe "transform/6 with use_common: true, transform: true" do
    test "transforms valid JSON body to Response struct" do
      body = %{"data" => [], "request_id" => "req_123"}
      status = 200
      headers = %{"content-type" => ["application/json"]}

      result = Transform.transform(body, status, headers, nil, true, true)

      assert %Response{
        data: [],
        status: :ok,
        request_id: "req_123",
        headers: %{"content-type" => ["application/json"]}
      } = result
    end

    test "transforms error response with status code" do
      body = %{"error" => %{"type" => "not_found"}}
      status = 404
      headers = %{}

      result = Transform.transform(body, status, headers, nil, true, true)

      assert %Response{status: :not_found} = result
    end

    test "transforms JSON string body" do
      body = ~s({"data": [], "request_id": "req_456"})
      status = 200
      headers = %{}

      result = Transform.transform(body, status, headers, nil, true, true)

      assert %Response{
        data: [],
        status: :ok,
        request_id: "req_456"
      } = result
    end

    test "returns DecodeError for invalid JSON string" do
      body = "invalid json {"
      status = 200
      headers = %{}

      result = Transform.transform(body, status, headers, nil, true, true)

      assert %DecodeError{reason: _} = result
    end

    test "handles unknown status codes" do
      body = %{"data" => []}
      status = 999
      headers = %{}

      result = Transform.transform(body, status, headers, nil, true, true)

      assert %Response{status: :unknown} = result
    end
  end

  describe "transform/6 with use_common: false, transform: true" do
    test "transforms data without wrapping in Response" do
      body = %{"data" => [%{"id" => "123"}]}

      result = Transform.transform(body, 200, %{}, nil, false, true)

      assert result == %{"data" => [%{"id" => "123"}]}
    end

    test "returns data as-is when nil" do
      result = Transform.transform(nil, 200, %{}, nil, false, true)

      assert result == nil
    end
  end

  describe "transform/6 with transform: false" do
    test "returns body as-is without transformation" do
      body = %{"raw" => "data"}

      result = Transform.transform(body, 200, %{}, nil, true, false)

      assert result == %{"raw" => "data"}
    end

    test "returns string body as-is" do
      body = "raw text response"

      result = Transform.transform(body, 200, %{}, nil, false, false)

      assert result == "raw text response"
    end
  end

  describe "transform_stream/3" do
    test "processes successful streaming data with 200 status" do
      data = ~s({"suggestion": "test suggestion"})
      req = %{}
      resp = %{status: 200}

      collector = fn suggestion ->
        send(self(), {:suggestion, suggestion})
      end

      result = Transform.transform_stream({:data, data}, {req, resp}, collector)

      assert {:cont, {^req, ^resp}} = result
      assert_receive {:suggestion, "test suggestion"}
    end

    test "handles error status by storing body" do
      data = "error response"
      req = %{}
      resp = %{status: 400}
      collector = fn _ -> :ok end

      result = Transform.transform_stream({:data, data}, {req, resp}, collector)

      assert {:cont, {^req, updated_resp}} = result
      assert updated_resp.body == "error response"
    end
  end

  describe "preprocess_data/2" do
    test "returns data as-is when model is nil" do
      data = %{"key" => "value"}

      result = Transform.preprocess_data(nil, data)

      assert result == %{"key" => "value"}
    end

    test "returns list data as-is when model is nil" do
      data = [%{"id" => "1"}, %{"id" => "2"}]

      result = Transform.preprocess_data(nil, data)

      assert result == [%{"id" => "1"}, %{"id" => "2"}]
    end

    test "returns primitive data as-is" do
      assert Transform.preprocess_data(nil, "string") == "string"
      assert Transform.preprocess_data(nil, 123) == 123
      assert Transform.preprocess_data(nil, true) == true
    end

    test "processes list of data with model" do
      data = [%{"id" => "1"}, %{"id" => "2"}]

      result = Transform.preprocess_data(ExNylas.Grant, data)

      assert is_list(result)
      assert length(result) == 2
      assert Enum.all?(result, &match?(%ExNylas.Grant{}, &1))
    end

    test "logs validation warnings when data doesn't match schema" do
      import ExUnit.CaptureLog

      # This should cause validation warnings due to type mismatch
      data = %{"created_at" => "not_an_integer"}

      log = capture_log(fn ->
        Transform.preprocess_data(ExNylas.Grant, data)
      end)

      assert log =~ "Validation error while transforming"
    end
  end
end
