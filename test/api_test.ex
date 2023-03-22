defmodule ExNylasTest.API do
  use ExUnit.Case, async: true

  test "header_bearer raises an error if connection struct lacks `access_token`" do
    assert_raise RuntimeError, fn ->
      ExNylas.API.header_bearer(%ExNylas.Connection{})
    end
  end

  test "header_bearer returns the correct headers" do
    h = ExNylas.API.header_bearer(%ExNylas.Connection{access_token: "1234", api_version: 2.7})
    assert h == [
      authorization: "Bearer 1234",
      "Nylas-API-Version": 2.7, accept: "application/json",
      "user-agent": "ExNylas/" <> Mix.Project.config()[:version]
    ]
  end

  test "header_basic raises an error if connection struct lacks `client_secret`" do
    assert_raise RuntimeError, fn ->
      ExNylas.API.header_basic(%ExNylas.Connection{})
    end
  end

  test "header_basic returns the correct headers" do
    h = ExNylas.API.header_basic(%ExNylas.Connection{client_secret: "1234", api_version: 2.7})
    assert h == [
      authorization: "Basic MTIzNDo=",
      "Nylas-API-Version": 2.7, accept: "application/json",
      "user-agent": "ExNylas/" <> Mix.Project.config()[:version]
    ]
  end

  test "handle_response returns untransformed body if no struct name is supplied" do
    assert ExNylas.API.handle_response({:ok, %HTTPoison.Response{status_code: 200, body: %{id: "1234"}}}) == {:ok, %{id: "1234"}}
  end

  test "handle_response returns an error tuple if the status code > 299" do
    assert ExNylas.API.handle_response({:ok, %HTTPoison.Response{status_code: 401, body: %{errorMessage: "Invalid credentials"}}}) == {:error, %{errorMessage: "Invalid credentials"}}
  end

  test "handle_response returns an error tuple if HTTPoison returns an error" do
    assert ExNylas.API.handle_response({:error, %HTTPoison.Error{reason: "some reason"}}) == {:error, "some reason"}
  end

  test "handle_response returns transformed body if struct name is supplied" do
    assert ExNylas.API.handle_response({:ok, %HTTPoison.Response{status_code: 200, body: %{"display_name" => "1234"}}}, ExNylas.Label) == {:ok, %ExNylas.Label{display_name: "1234"}}
  end

end
