defmodule ExNylasTest.API do
  use ExUnit.Case, async: true
  alias ExNylas.Connection, as: Conn

  describe "auth_bearer/1" do
    test "returns a bearer tuple with the access token" do
      assert ExNylas.API.auth_bearer(%Conn{grant_id: "me", access_token: "1234"}) == {:bearer, "1234"}
    end

    test "raises an error if access_token is not present" do
      assert_raise ExNylasError, "Error: \"access_token must be present when using grant_id='me'\"", fn ->
        ExNylas.API.auth_bearer(%Conn{grant_id: "me"})
      end
    end

    test "returns a bearer tuple with API key" do
      assert ExNylas.API.auth_bearer(%Conn{grant_id: "1234", api_key: "1234"}) == {:bearer, "1234"}
    end

    test "raises an error if api_key is not present" do
      assert_raise ExNylasError, "Error: \"missing value for api_key\"", fn ->
        ExNylas.API.auth_bearer(%Conn{grant_id: "1234"})
      end
    end
  end

  describe "base_headers/1" do
    test "returns the base headers with any additional headers" do
      h = ExNylas.API.base_headers(["X-Test": "test"])
      assert {:"X-Test", "test"} in h
    end

    test "additional headers override the base headers" do
      h = ExNylas.API.base_headers([accept: "test"])
      assert {:accept, "test"} in h and {:accept, "application/json"} not in h
    end
  end

  describe "build_multipart/2 with attachments" do
    test "returns a stream for the body" do
      {stream, _, _} = ExNylas.API.build_multipart(%{test: "test"}, ["./test/fixtures/test_attachment.txt"])
      assert is_function(stream)
    end

    test "returns the content type with boundary" do
      {_, content_type, _} = ExNylas.API.build_multipart(%{test: "test"}, [])
      assert String.contains?(content_type, "multipart/form-data") and String.contains?(content_type, "boundary")
    end

    test "returns the content length" do
      {_, _, content_length} = ExNylas.API.build_multipart(%{test: "test"}, [])
      assert content_length > 0
    end
  end

  describe "build_multipart/2 without attachments" do
    test "returns a stream for the body" do
      {stream, _, _} = ExNylas.API.build_multipart(%{test: "test"}, [])
      assert is_function(stream)
    end

    test "returns the content type with boundary" do
      {_, content_type, _} = ExNylas.API.build_multipart(%{test: "test"}, [])
      assert String.contains?(content_type, "multipart/form-data") and String.contains?(content_type, "boundary")
    end

    test "returns the content length" do
      {_, _, content_length} = ExNylas.API.build_multipart(%{test: "test"}, [])
      assert content_length > 0
    end
  end

  describe "handle_response/3" do
    test "returns {:ok, _} for 2xx responses" do
      res = ExNylas.API.handle_response({:ok, %{status: 200}})
      assert match?({:ok, _}, res)
    end

    test "returns {:error, _} for non-2xx responses" do
      res = ExNylas.API.handle_response({:error, %{status: 400}})
      assert match?({:error, _}, res)
    end

    test "returns {:error, reason} for HTTP issues, e.g. timeout" do
      assert ExNylas.API.handle_response({:error, "timeout"}) == {:error, "timeout"}
    end

    test "returns common response struct if use_common_response is true" do
      res = %{
        status: 200,
        body: %{"request_id" => "1234", "data" => %{"grant_id" => "abcd", "name" => "test", "id" => "abcd"}},
        headers: %{"content-type" => ["application/json"]}
      }
      assert match?({:ok, %ExNylas.Response{}}, ExNylas.API.handle_response({:ok, res}, ExNylas.Folder, true))
    end

    test "does not return common response struct if use_common_response is false" do
      res = %{
        status: 200,
        body: %{"grant_id" => "abcd", "name" => "test", "id" => "abcd"},
        headers: %{"content-type" => ["application/json"]}
      }
      assert match?({:ok, %ExNylas.Folder{}}, ExNylas.API.handle_response({:ok, res}, ExNylas.Folder, false))
    end

    test "only decodes JSON responses" do
      res = ExNylas.API.handle_response({:ok, %{status: 200, body: "test"}})
      assert res == {:ok, "test"}
    end

    test "transforms into the requested struct" do
      res = %{
        status: 200,
        body: %{"request_id" => "1234", "data" => %{"grant_id" => "abcd", "name" => "test", "id" => "abcd"}},
        headers: %{"content-type" => ["application/json"]}
      }
      assert match?({:ok, %ExNylas.Response{data: %ExNylas.Folder{}}}, ExNylas.API.handle_response({:ok, res}, ExNylas.Folder))
    end
  end

  describe "handle_stream/1" do
    test "returns a function" do
      assert is_function(ExNylas.API.handle_stream(fn -> {:ok, "test"} end))
    end
  end
end
