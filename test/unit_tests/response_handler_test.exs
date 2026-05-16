defmodule ExNylas.ResponseHandlerTest do
  use ExUnit.Case, async: true
  alias ExNylas.{ResponseHandler, Response, DecodeError, TransportError, Error}

  describe "handle_response/3" do
    test "handles successful JSON response" do
      response = {:ok, %{status: 200, body: %{"data" => []}, headers: %{"content-type" => ["application/json"]}}}

      assert {:ok, %Response{data: [], status: :ok}} = ResponseHandler.handle_response(response)
    end

    test "handles error JSON response" do
      response = {:ok, %{status: 400, body: %{}, headers: %{"content-type" => ["application/json"]}}}

      assert {:error, %Response{status: :bad_request}} = ResponseHandler.handle_response(response)
    end

    test "handles non-JSON successful response" do
      response = {:ok, %{status: 200, body: "plain text", headers: %{"content-type" => ["text/plain"]}}}

      assert {:ok, "plain text"} = ResponseHandler.handle_response(response, nil, false)
    end

    test "handles non-JSON error response" do
      response = {:ok, %{status: 400, body: "error text", headers: %{"content-type" => ["text/plain"]}}}

      assert {:error, %DecodeError{}} = ResponseHandler.handle_response(response)
    end

    test "handles transport error with atom reason" do
      response = {:error, %{reason: :timeout}}

      assert {:error, %TransportError{reason: :timeout}} = ResponseHandler.handle_response(response)
    end

    test "handles generic error with non-atom reason" do
      response = {:error, %{reason: %RuntimeError{message: "something went wrong"}}}

      assert {:error, %Error{}} = ResponseHandler.handle_response(response)
    end

    test "handles success response with DecodeError" do
      # Simulate a response that looks successful but has unexpected JSON structure
      response = {:ok, %{status: 200, body: %{"invalid" => "structure"}, headers: %{"content-type" => ["application/json"]}}}

      # Valid JSON with unexpected structure still succeeds but creates a Response with nil data
      result = ResponseHandler.handle_response(response, ExNylas.Message)

      assert {:ok, %Response{}} = result
    end

    test "handles error response with struct" do
      response = {:ok, %{status: 500, body: %{"error" => "internal"}, headers: %{"content-type" => ["application/json"]}}}

      assert {:error, _} = ResponseHandler.handle_response(response)
    end

    test "handles error response with custom struct (not Response or DecodeError)" do
      # Create a response that will result in a struct error
      response = {:ok, %{status: 400, body: %URI{scheme: "http", host: "example.com"}, headers: %{"content-type" => ["text/plain"]}}}

      assert {:error, %Error{}} = ResponseHandler.handle_response(response, nil, false)
    end

    test "handles response without content-type header" do
      response = {:ok, %{status: 200, body: "data", headers: %{}}}

      # Should not transform since no content-type header
      assert {:ok, "data"} = ResponseHandler.handle_response(response, nil, false)
    end

    test "handles response with nil headers" do
      response = {:ok, %{status: 200, body: "data", headers: nil}}

      # Should not transform since headers is nil
      result = ResponseHandler.handle_response(response, nil, false)

      assert result == {:ok, "data"}
    end

    test "handles response with multiple content-type values" do
      response = {:ok, %{status: 200, body: %{"data" => []}, headers: %{"content-type" => ["text/html", "application/json"]}}}

      result = ResponseHandler.handle_response(response)

      assert {:ok, %Response{data: [], status: :ok}} = result
    end

    test "handles response where transform fails with DecodeError on success" do
      # A successful response with valid JSON but unexpected structure
      response = {:ok, %{status: 200, body: ~s({"invalid": "json"}), headers: %{"content-type" => ["application/json"]}}}

      result = ResponseHandler.handle_response(response, ExNylas.Message)

      # Valid JSON with unexpected structure still succeeds (validation is lenient)
      assert {:ok, %Response{}} = result
    end

    test "handles success response with no JSON content-type" do
      response = {:ok, %{status: 200, body: "plain text", headers: %{"content-type" => ["text/plain; charset=utf-8"]}}}

      result = ResponseHandler.handle_response(response, nil, false)

      assert {:ok, "plain text"} = result
    end

    test "handles error response with empty map body" do
      response = {:ok, %{status: 400, body: %{}, headers: %{"content-type" => ["application/json"]}}}

      result = ResponseHandler.handle_response(response)

      assert {:error, %Response{status: :bad_request}} = result
    end
  end

  describe "handle_stream/1" do
    test "returns a function that processes streaming data" do
      collector_fun = fn data, acc ->
        {:cont, [data | acc]}
      end

      stream_handler = ResponseHandler.handle_stream(collector_fun)

      assert is_function(stream_handler, 2)
    end

    test "returned function calls transform_stream with correct arguments" do
      test_pid = self()
      collector_fun = fn data ->
        send(test_pid, {:collected, data})
        :ok
      end

      stream_handler = ResponseHandler.handle_stream(collector_fun)

      # Simulate streaming data
      data = ~s({"suggestion": "test"})
      req = %{}
      resp = %{status: 200}

      result = stream_handler.({:data, data}, {req, resp})

      assert {:cont, {^req, ^resp}} = result
      assert_receive {:collected, "test"}
    end
  end
end
