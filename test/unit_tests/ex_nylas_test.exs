defmodule ExNylasTest.ExNylas do
  use ExUnit.Case, async: true

  describe "from_struct/1" do
    test "converts struct to map with atom keys" do
      grant = %ExNylas.Grant{
        id: "grant_123",
        provider: "google",
        email: "test@example.com"
      }

      result = ExNylas.from_struct(grant)

      assert is_map(result)
      refute is_struct(result)
      assert result[:id] == "grant_123"
      assert result[:provider] == "google"
      assert result[:email] == "test@example.com"
    end

    test "returns non-struct payloads unchanged" do
      payload = %{"foo" => "bar", "nested" => %{"baz" => "qux"}}

      result = ExNylas.from_struct(payload)

      assert result == payload
    end

    test "returns primitive values unchanged" do
      assert ExNylas.from_struct("string") == "string"
      assert ExNylas.from_struct(123) == 123
      assert ExNylas.from_struct(true) == true
      assert ExNylas.from_struct(nil) == nil
    end
  end

  describe "format_module_name/1" do
    test "capitalizes module name and returns atom" do
      assert ExNylas.format_module_name(ExNylas.Grant) == :"ExNylas.Grant"
    end

    test "handles atom names" do
      assert ExNylas.format_module_name(:test_module) == :test_module
    end
  end
end
