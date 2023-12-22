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
  end

  describe "auth_basic/1" do
    test "returns a basic tuple with client id and secret" do
      assert ExNylas.API.auth_basic(%Conn{client_id: "1234", client_secret: "1234"}) == {:basic, "1234:1234"}
    end

    test "raises an error if client_id is not present" do
      assert_raise ExNylasError, "Error: \"client_id must be present to use basic auth\"", fn ->
        ExNylas.API.auth_basic(%Conn{client_secret: "1234"})
      end
    end

    test "raises an error if client_secret is not present" do
      assert_raise ExNylasError, "Error: \"client_secret must be present to use basic auth\"", fn ->
        ExNylas.API.auth_basic(%Conn{client_id: "1234"})
      end
    end
  end

  describe "base_headers/1" do
    test "returns the base headers with additional headers" do
      h = ExNylas.API.base_headers(["X-Test": "test"])
      assert {:"X-Test", "test"} in h
    end
  end

  describe "process_request_body/1" do
    test "returns the body if it is a map" do
      assert ExNylas.API.process_request_body(%{test: "test"}) == "{\"test\":\"test\"}"
    end

    test "returns the body if it is a struct" do
      res = ExNylas.API.process_request_body(%ExNylas.Model.Folder.Build{name: "test"})
      assert !String.contains?(res, "__struct__")
    end

    test "does not attempt to encode data that isn't a map or struct" do
      assert ExNylas.API.process_request_body([1, 2, 3, 4]) == [1, 2, 3, 4]
    end
  end
end
