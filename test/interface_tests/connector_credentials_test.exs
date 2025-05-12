defmodule ExNylasTest.ConnectorCredentials do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper
  alias ExNylas.ConnectorCredentials

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "connector credentials list" do
    test "calls GET", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "GET"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.list(default_connection(bypass), "google")
    end

    test "includes the provider in the path", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v3/connectors/google/creds", fn conn ->
        conn
          |> Plug.Conn.resp(200,~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        ConnectorCredentials.list(default_connection(bypass), "google")
    end

    test "returns the ok tuple for success", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(200, ~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        assert {:ok, _} = ConnectorCredentials.list(default_connection(bypass), "google")
    end

    test "returns the error tuple for failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        assert {:error, _} = ConnectorCredentials.list(default_connection(bypass), "google")
    end
  end

  describe "connector credentials list!" do
    test "calls GET", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "GET"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.list(default_connection(bypass), "google")
    end

    test "raises an error if a non-success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{"error": {"type": "bad_request"}}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        err = "Error: %ExNylas.Response{data: nil, next_cursor: nil, prev_cursor: nil, request_id: nil, status: :bad_request, error: %ExNylas.Error{message: nil, provider_error: nil, type: \"bad_request\"}}"

        assert_raise ExNylasError, err, fn ->
          ConnectorCredentials.list!(default_connection(bypass), "google")
        end
    end

    test "does not raise an error if a success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      result = ConnectorCredentials.list!(default_connection(bypass), "google")

      assert result == %ExNylas.Response{
        data: [],
        next_cursor: nil,
        request_id: nil,
        status: :ok,
        error: nil
      }
    end
  end

  describe "connector credentials create" do
    test "calls POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "POST"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.create(default_connection(bypass), "google", %{})
    end

    test "returns the ok tuple for success", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(200, ~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        assert {:ok, _} = ConnectorCredentials.create(default_connection(bypass), "google", %{})
    end

    test "returns the error tuple for failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        assert {:error, _} = ConnectorCredentials.create(default_connection(bypass), "google", %{})
    end
  end

  describe "connector credentials create!" do
    test "calls POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "POST"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.create!(default_connection(bypass), "google", %{})
    end

    test "raises an error if a non-success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{"error": {"type": "bad_request"}}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        err = "Error: %ExNylas.Response{data: nil, next_cursor: nil, prev_cursor: nil, request_id: nil, status: :bad_request, error: %ExNylas.Error{message: nil, provider_error: nil, type: \"bad_request\"}}"

        assert_raise ExNylasError, err, fn ->
          ConnectorCredentials.create!(default_connection(bypass), "google", %{})
        end
    end
  end

  describe "connector credentials find" do
    test "calls GET", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "GET"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.find(default_connection(bypass), "google", "1234")
    end

    test "includes the provider and id in the path", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v3/connectors/google/creds/1234", fn conn ->
        conn
          |> Plug.Conn.resp(200,~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        ConnectorCredentials.find(default_connection(bypass), "google", "1234")
    end
  end

  describe "connector credentials find!" do
    test "calls GET", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "GET"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.find!(default_connection(bypass), "google", "1234")
    end

    test "raises an error if a non-success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{"error": {"type": "bad_request"}}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        err = "Error: %ExNylas.Response{data: nil, next_cursor: nil, prev_cursor: nil, request_id: nil, status: :bad_request, error: %ExNylas.Error{message: nil, provider_error: nil, type: \"bad_request\"}}"

        assert_raise ExNylasError, err, fn ->
          ConnectorCredentials.find!(default_connection(bypass), "google", "1234")
        end
    end
  end

  describe "connector credentials delete" do
    test "calls DELETE", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "DELETE"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.delete(default_connection(bypass), "google", "1234")
    end

    test "includes the provider and id in the path", %{bypass: bypass} do
      Bypass.expect_once(bypass, "DELETE", "/v3/connectors/google/creds/1234", fn conn ->
        conn
          |> Plug.Conn.resp(200,~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        ConnectorCredentials.delete(default_connection(bypass), "google", "1234")
    end
  end

  describe "connector credentials delete!" do
    test "calls DELETE", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "DELETE"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.delete!(default_connection(bypass), "google", "1234")
    end

    test "raises an error if a non-success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{"error": {"type": "bad_request"}}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        err = "Error: %ExNylas.Response{data: nil, next_cursor: nil, prev_cursor: nil, request_id: nil, status: :bad_request, error: %ExNylas.Error{message: nil, provider_error: nil, type: \"bad_request\"}}"

        assert_raise ExNylasError, err, fn ->
          ConnectorCredentials.delete!(default_connection(bypass), "google", "1234")
        end
    end
  end

  describe "connector credentials update" do
    test "calls PATCH", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "PATCH"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.update(default_connection(bypass), "google", "1234", %{})
    end

    test "passes the request body", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        assert body == ~s<{"foo":"bar"}>

        conn
          |> Plug.Conn.resp(200, ~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.update(default_connection(bypass), "google", "1234", %{"foo" => "bar"})
    end
  end

  describe "connector credentials update!" do
    test "calls PATCH", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "PATCH"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      ConnectorCredentials.update!(default_connection(bypass), "google", "1234", %{})
    end

    test "raises an error if a non-success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{"error": {"type": "bad_request"}}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        err = "Error: %ExNylas.Response{data: nil, next_cursor: nil, prev_cursor: nil, request_id: nil, status: :bad_request, error: %ExNylas.Error{message: nil, provider_error: nil, type: \"bad_request\"}}"

        assert_raise ExNylasError, err, fn ->
          ConnectorCredentials.update!(default_connection(bypass), "google", "1234", %{})
        end
    end
  end
end
