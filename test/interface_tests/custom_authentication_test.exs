defmodule ExNylasTest.CustomAuthentication do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper
  alias ExNylas.CustomAuthentication

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "custom auth connect" do
    test "calls POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "POST"

        conn
        |> Plug.Conn.resp(200, ~s<{"access_token": "abcd"}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      CustomAuthentication.connect(default_connection(bypass), %{})
    end

    test "includes the body in the request", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"foo":"bar"}>

        conn
        |> Plug.Conn.resp(200, ~s<{"access_token": "abcd"}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      CustomAuthentication.connect(default_connection(bypass), %{foo: "bar"})
    end

    test "returns ok tuple for success", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      assert {:ok, _} = CustomAuthentication.connect(default_connection(bypass), %{})
    end

    test "returns error tuple for failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(400, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      assert {:error, _} = CustomAuthentication.connect(default_connection(bypass), %{})
    end
  end

  describe "custom auth connect!" do
    test "does not raise an error if success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      res = CustomAuthentication.connect!(default_connection(bypass), %{})

      assert %ExNylas.Response{
        data: nil,
        next_cursor: nil,
        request_id: nil,
        status: :ok,
        error: nil,
        headers: %{"content-type" => ["application/json"]} = _headers
      } = res
    end

    test "raises on error", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(400, ~s<{"error": {"type": "bad_request"}}>)
      end)

      err = "Error: %ExNylas.Response{data: nil, next_cursor: nil, prev_cursor: nil, request_id: nil, status: :bad_request, error: %ExNylas.Error{message: nil, provider_error: nil, type: \"bad_request\"}}"

      assert_raise ExNylasError, err, fn ->
        CustomAuthentication.connect!(default_connection(bypass), %{})
      end
    end
  end
end
