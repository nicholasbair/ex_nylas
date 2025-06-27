defmodule ExNylas.ResponseTest do
  use ExUnit.Case, async: true
  alias ExNylas.Response

  describe "Response schema" do
    test "creates a valid response with all fields" do
      params = %{
        "data" => %{"items" => [%{"id" => "1"}, %{"id" => "2"}]},
        "headers" => %{"content-type" => "application/json"},
        "next_cursor" => "next_page_token",
        "prev_cursor" => "prev_page_token",
        "request_id" => "req_123",
        "status" => :success,
        "error" => %{
          "message" => "No error",
          "type" => "none"
        }
      }
      changeset = Response.changeset(%Response{}, params)
      assert changeset.valid?
      response = Ecto.Changeset.apply_changes(changeset)
      assert response.data == %{"items" => [%{"id" => "1"}, %{"id" => "2"}]}
      assert response.headers == %{"content-type" => "application/json"}
      assert response.next_cursor == "next_page_token"
      assert response.prev_cursor == "prev_page_token"
      assert response.request_id == "req_123"
      assert response.status == :success
      assert response.error.message == "No error"
      assert response.error.type == "none"
    end

    test "handles data as list" do
      params = %{
        "data" => [%{"id" => "1"}, %{"id" => "2"}],
        "status" => :success
      }
      changeset = Response.changeset(%Response{}, params)
      assert changeset.valid?
      response = Ecto.Changeset.apply_changes(changeset)
      assert response.data == [%{"id" => "1"}, %{"id" => "2"}]
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "data" => nil,
        "headers" => nil,
        "next_cursor" => nil,
        "prev_cursor" => nil,
        "request_id" => nil,
        "status" => nil,
        "error" => nil
      }
      changeset = Response.changeset(%Response{}, params)
      assert changeset.valid?
      response = Ecto.Changeset.apply_changes(changeset)
      assert response.data == nil
      assert response.headers == nil
      assert response.next_cursor == nil
      assert response.prev_cursor == nil
      assert response.request_id == nil
      assert response.status == nil
      assert response.error == nil
    end

    test "handles empty map for headers" do
      params = %{"headers" => %{}, "status" => :success}
      changeset = Response.changeset(%Response{}, params)
      assert changeset.valid?
      response = Ecto.Changeset.apply_changes(changeset)
      assert response.headers == %{}
    end

    test "handles atom status values" do
      valid_statuses = [:success, :error, :pending]
      for status <- valid_statuses do
        params = %{"status" => status}
        changeset = Response.changeset(%Response{}, params)
        assert changeset.valid?, "Status #{status} should be valid"
        response = Ecto.Changeset.apply_changes(changeset)
        assert response.status == status
      end
    end

    test "creates minimal response with only status" do
      params = %{"status" => :success}
      changeset = Response.changeset(%Response{}, params)
      assert changeset.valid?
      response = Ecto.Changeset.apply_changes(changeset)
      assert response.status == :success
    end
  end
end
