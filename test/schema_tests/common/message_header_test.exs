defmodule ExNylas.MessageHeaderTest do
  use ExUnit.Case, async: true
  alias ExNylas.MessageHeader

  describe "MessageHeader schema" do
    test "creates a valid message header with all fields" do
      params = %{
        "name" => "Content-Type",
        "value" => "text/html; charset=UTF-8"
      }
      changeset = MessageHeader.changeset(%MessageHeader{}, params)
      assert changeset.valid?
      header = Ecto.Changeset.apply_changes(changeset)
      assert header.name == "Content-Type"
      assert header.value == "text/html; charset=UTF-8"
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "name" => nil,
        "value" => nil
      }
      changeset = MessageHeader.changeset(%MessageHeader{}, params)
      assert changeset.valid?
      header = Ecto.Changeset.apply_changes(changeset)
      assert header.name == nil
      assert header.value == nil
    end

    test "handles empty strings" do
      params = %{
        "name" => "",
        "value" => ""
      }
      changeset = MessageHeader.changeset(%MessageHeader{}, params)
      assert changeset.valid?
      header = Ecto.Changeset.apply_changes(changeset)
      assert header.name == nil
      assert header.value == nil
    end

    test "handles various header names and values" do
      test_cases = [
        {"From", "sender@example.com"},
        {"To", "recipient@example.com"},
        {"Subject", "Test Email"},
        {"Date", "Mon, 01 Jan 2024 12:00:00 +0000"},
        {"Message-ID", "<123456@example.com>"},
        {"X-Custom-Header", "custom-value"}
      ]

      for {name, value} <- test_cases do
        params = %{"name" => name, "value" => value}
        changeset = MessageHeader.changeset(%MessageHeader{}, params)
        assert changeset.valid?, "Header #{name} should be valid"
        header = Ecto.Changeset.apply_changes(changeset)
        assert header.name == name
        assert header.value == value
      end
    end

    test "handles special characters in name and value" do
      params = %{
        "name" => "X-Special-Header-123",
        "value" => "value with spaces and @#$% symbols"
      }
      changeset = MessageHeader.changeset(%MessageHeader{}, params)
      assert changeset.valid?
      header = Ecto.Changeset.apply_changes(changeset)
      assert header.name == "X-Special-Header-123"
      assert header.value == "value with spaces and @#$% symbols"
    end

    test "creates minimal header with only name" do
      params = %{"name" => "Test-Header"}
      changeset = MessageHeader.changeset(%MessageHeader{}, params)
      assert changeset.valid?
      header = Ecto.Changeset.apply_changes(changeset)
      assert header.name == "Test-Header"
      assert header.value == nil
    end

    test "creates minimal header with only value" do
      params = %{"value" => "test-value"}
      changeset = MessageHeader.changeset(%MessageHeader{}, params)
      assert changeset.valid?
      header = Ecto.Changeset.apply_changes(changeset)
      assert header.name == nil
      assert header.value == "test-value"
    end

    test "creates empty header" do
      params = %{}
      changeset = MessageHeader.changeset(%MessageHeader{}, params)
      assert changeset.valid?
      header = Ecto.Changeset.apply_changes(changeset)
      assert header.name == nil
      assert header.value == nil
    end
  end
end
