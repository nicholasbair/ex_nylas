defmodule ExNylasTest.UtilModules do
  use ExUnit.Case, async: true
  alias ExNylas.Connection, as: Conn

  describe "Auth.auth_bearer/1" do
    test "returns a bearer tuple with the access token" do
      assert ExNylas.Auth.auth_bearer(%Conn{grant_id: "me", access_token: "1234"}) == {:bearer, "1234"}
    end

    test "raises an error if access_token is not present" do
      assert_raise ExNylas.ValidationError, "Validation failed for access_token: access_token must be present when using grant_id='me'", fn ->
        ExNylas.Auth.auth_bearer(%Conn{grant_id: "me"})
      end
    end

    test "returns a bearer tuple with API key" do
      assert ExNylas.Auth.auth_bearer(%Conn{grant_id: "1234", api_key: "1234"}) == {:bearer, "1234"}
    end

    test "raises an error if api_key is not present" do
      assert_raise ExNylas.ValidationError, "Validation failed for api_key: missing value for api_key", fn ->
        ExNylas.Auth.auth_bearer(%Conn{grant_id: "1234"})
      end
    end
  end

  describe "API.base_headers/1" do
    test "returns the base headers with any additional headers" do
      h = ExNylas.API.base_headers(["X-Test": "test"])
      assert {:"X-Test", "test"} in h
    end

    test "additional headers override the base headers" do
      h = ExNylas.API.base_headers([accept: "test"])
      assert {:accept, "test"} in h and {:accept, "application/json"} not in h
    end
  end

  describe "Multipart.build_multipart/2 with attachments" do
    test "returns ok tuple with stream for the body" do
      assert {:ok, {stream, _, _}} = ExNylas.Multipart.build_multipart(%{test: "test"}, ["./test/fixtures/test_attachment.txt"])
      assert is_function(stream)
    end

    test "returns ok tuple with content type with boundary" do
      assert {:ok, {_, content_type, _}} = ExNylas.Multipart.build_multipart(%{test: "test"}, ["./test/fixtures/test_attachment.txt"])
      assert String.contains?(content_type, "multipart/form-data") and String.contains?(content_type, "boundary")
    end

    test "returns ok tuple with content length" do
      assert {:ok, {_, _, content_length}} = ExNylas.Multipart.build_multipart(%{test: "test"}, ["./test/fixtures/test_attachment.txt"])
      assert content_length > 0
    end

    test "handles attachments with CID" do
      assert {:ok, {stream, _, _}} = ExNylas.Multipart.build_multipart(%{test: "test"}, [{"cid:123", "./test/fixtures/test_attachment.txt"}])
      assert is_function(stream)
    end

    test "returns error tuple with ExNylas.FileError when file does not exist" do
      assert {:error, %ExNylas.FileError{} = error} = ExNylas.Multipart.build_multipart(%{test: "test"}, ["./nonexistent.txt"])
      assert error.path == "./nonexistent.txt"
      assert error.reason == :enoent
      assert error.message =~ ~r/Failed to read file at .*nonexistent\.txt: file does not exist/
    end

    test "returns error tuple with ExNylas.FileError with CID when file does not exist" do
      assert {:error, %ExNylas.FileError{} = error} = ExNylas.Multipart.build_multipart(%{test: "test"}, [{"cid:123", "./nonexistent.txt"}])
      assert error.path == "./nonexistent.txt"
      assert error.reason == :enoent
      assert error.message =~ ~r/Failed to read file at .*nonexistent\.txt: file does not exist/
    end
  end

  describe "Multipart.build_multipart/2 without attachments" do
    test "returns ok tuple with stream for the body" do
      assert {:ok, {stream, _, _}} = ExNylas.Multipart.build_multipart(%{test: "test"}, [])
      assert is_function(stream)
    end

    test "returns ok tuple with content type with boundary" do
      assert {:ok, {_, content_type, _}} = ExNylas.Multipart.build_multipart(%{test: "test"}, [])
      assert String.contains?(content_type, "multipart/form-data") and String.contains?(content_type, "boundary")
    end

    test "returns ok tuple with content length" do
      assert {:ok, {_, _, content_length}} = ExNylas.Multipart.build_multipart(%{test: "test"}, [])
      assert content_length > 0
    end
  end

  describe "Multipart.build_raw_multipart/1" do
    test "returns a stream for the body" do
      {stream, _, _} = ExNylas.Multipart.build_raw_multipart("test mime content")
      assert is_function(stream)
    end

    test "returns the content type with boundary" do
      {_, content_type, _} = ExNylas.Multipart.build_raw_multipart("test mime content")
      assert String.contains?(content_type, "multipart/form-data") and String.contains?(content_type, "boundary")
    end

    test "returns the content length" do
      {_, _, content_length} = ExNylas.Multipart.build_raw_multipart("test mime content")
      assert content_length > 0
    end
  end

  describe "ResponseHandler.handle_response/3" do
    test "returns {:ok, _} for 2xx responses" do
      res = ExNylas.ResponseHandler.handle_response({:ok, %{status: 200}})
      assert match?({:ok, _}, res)
    end

    test "returns {:error, _} for non-2xx responses" do
      res = ExNylas.ResponseHandler.handle_response({:error, %{status: 400}})
      assert match?({:error, _}, res)
    end

    test "returns {:error, reason} for HTTP issues, e.g. timeout" do
      assert ExNylas.ResponseHandler.handle_response({:error, "timeout"}) == {:error, "timeout"}
    end

    test "returns common response struct if use_common_response is true" do
      res = %{
        status: 200,
        body: %{"request_id" => "1234", "data" => %{"grant_id" => "abcd", "name" => "test", "id" => "abcd"}},
        headers: %{"content-type" => ["application/json"]}
      }
      assert match?({:ok, %ExNylas.Response{}}, ExNylas.ResponseHandler.handle_response({:ok, res}, ExNylas.Folder, true))
    end

    test "does not return common response struct if use_common_response is false" do
      res = %{
        status: 200,
        body: %{"grant_id" => "abcd", "name" => "test", "id" => "abcd"},
        headers: %{"content-type" => ["application/json"]}
      }
      assert match?({:ok, %ExNylas.Folder{}}, ExNylas.ResponseHandler.handle_response({:ok, res}, ExNylas.Folder, false))
    end

    test "only decodes JSON responses" do
      res = ExNylas.ResponseHandler.handle_response({:ok, %{status: 200, body: "test"}})
      assert res == {:ok, %{status: 200, body: "test"}}
    end

    test "transforms into the requested struct" do
      res = %{
        status: 200,
        body: %{"request_id" => "1234", "data" => %{"grant_id" => "abcd", "name" => "test", "id" => "abcd"}},
        headers: %{"content-type" => ["application/json"]}
      }
      assert match?({:ok, %ExNylas.Response{data: %ExNylas.Folder{}}}, ExNylas.ResponseHandler.handle_response({:ok, res}, ExNylas.Folder))
    end

    test "handles responses with missing headers" do
      res = %{status: 200, body: "test"}
      result = ExNylas.ResponseHandler.handle_response({:ok, res})
      assert match?({:ok, _}, result)
    end

    test "handles responses with nil content-type" do
      res = %{
        status: 200,
        body: "test",
        headers: %{}
      }
      result = ExNylas.ResponseHandler.handle_response({:ok, res})
      assert match?({:ok, _}, result)
    end
  end

  describe "ResponseHandler.handle_stream/1" do
    test "returns a function" do
      assert is_function(ExNylas.ResponseHandler.handle_stream(fn -> {:ok, "test"} end))
    end
  end

  describe "Telemetry.maybe_attach_telemetry/2" do
    test "attaches telemetry when telemetry is true" do
      conn = %Conn{telemetry: true}
      req = Req.new()

      result = ExNylas.Telemetry.maybe_attach_telemetry(req, conn)
      assert is_map(result)
    end

    test "does not attach telemetry when telemetry is false" do
      conn = %Conn{telemetry: false}
      req = Req.new()

      result = ExNylas.Telemetry.maybe_attach_telemetry(req, conn)
      assert result == req
    end

    test "does not attach telemetry when telemetry is not set" do
      conn = %Conn{}
      req = Req.new()

      result = ExNylas.Telemetry.maybe_attach_telemetry(req, conn)
      assert result == req
    end
  end
end
