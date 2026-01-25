defmodule ExNylasTest.FileError do
  use ExUnit.Case, async: true

  describe "ExNylas.FileError" do
    test "formats common file errors with descriptive messages" do
      error = ExNylas.FileError.exception({"/path/to/file.txt", :enoent})
      assert error.message == "Failed to read file at /path/to/file.txt: file does not exist"
      assert error.path == "/path/to/file.txt"
      assert error.reason == :enoent
    end

    test "formats permission denied error" do
      error = ExNylas.FileError.exception({"/path/to/file.txt", :eacces})
      assert error.message == "Failed to read file at /path/to/file.txt: permission denied"
      assert error.path == "/path/to/file.txt"
      assert error.reason == :eacces
    end

    test "formats is a directory error" do
      error = ExNylas.FileError.exception({"/path/to/dir", :eisdir})
      assert error.message == "Failed to read file at /path/to/dir: is a directory"
      assert error.path == "/path/to/dir"
      assert error.reason == :eisdir
    end

    test "formats unknown errors" do
      error = ExNylas.FileError.exception({"/path/to/file.txt", :unknown_reason})
      assert error.message == "Failed to read file at /path/to/file.txt: :unknown_reason"
      assert error.path == "/path/to/file.txt"
      assert error.reason == :unknown_reason
    end

    test "can be raised with custom error reason" do
      assert_raise ExNylas.FileError, ~r/Failed to read file/, fn ->
        raise ExNylas.FileError, {"/some/file.txt", :enoent}
      end
    end
  end
end
