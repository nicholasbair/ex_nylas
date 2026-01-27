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

    test "can be rescued and fields accessed" do
      try do
        raise ExNylas.FileError, {"/path/to/file.txt", :eacces}
      rescue
        e in ExNylas.FileError ->
          assert e.path == "/path/to/file.txt"
          assert e.reason == :eacces
          assert e.message =~ "permission denied"
      end
    end
  end

  describe "exception/1 with binary input" do
    test "creates exception from custom message" do
      error = ExNylas.FileError.exception("Cannot access file system")

      assert error.message == "Cannot access file system"
      assert error.path == nil
      assert error.reason == :unknown
    end

    test "can be raised with binary" do
      assert_raise ExNylas.FileError, "File operation failed", fn ->
        raise ExNylas.FileError, "File operation failed"
      end
    end
  end

  describe "exception/1 with keyword list input" do
    test "creates exception from keyword list with all fields" do
      error = ExNylas.FileError.exception(
        path: "/tmp/upload.pdf",
        reason: :enospc,
        message: "Disk full"
      )

      assert error.message == "Disk full"
      assert error.path == "/tmp/upload.pdf"
      assert error.reason == :enospc
    end

    test "creates exception from keyword list with path and reason" do
      error = ExNylas.FileError.exception(
        path: "/var/log/app.log",
        reason: :eacces
      )

      assert error.message == "Failed to read file at /var/log/app.log: permission denied"
      assert error.path == "/var/log/app.log"
      assert error.reason == :eacces
    end

    test "creates exception from keyword list with only reason" do
      error = ExNylas.FileError.exception(reason: :eisdir)

      assert error.message == "File operation failed: is a directory"
      assert error.path == nil
      assert error.reason == :eisdir
    end

    test "can be raised with keyword list" do
      assert_raise ExNylas.FileError, "Not enough memory", fn ->
        raise ExNylas.FileError, [path: "/file.txt", reason: :enomem, message: "Not enough memory"]
      end
    end
  end

  describe "exception/1 with map input (atom keys)" do
    test "creates exception from map with all fields" do
      error = ExNylas.FileError.exception(%{
        path: "/home/user/document.pdf",
        reason: :enotdir,
        message: "Parent is not a directory"
      })

      assert error.message == "Parent is not a directory"
      assert error.path == "/home/user/document.pdf"
      assert error.reason == :enotdir
    end

    test "creates exception from map with path and reason" do
      error = ExNylas.FileError.exception(%{
        path: "/file.txt",
        reason: :enoent
      })

      assert error.message == "Failed to read file at /file.txt: file does not exist"
      assert error.path == "/file.txt"
      assert error.reason == :enoent
    end

    test "creates exception from empty map" do
      error = ExNylas.FileError.exception(%{})

      assert error.message == "File operation failed: :unknown"
      assert error.path == nil
      assert error.reason == :unknown
    end
  end

  describe "exception/1 with map input (string keys)" do
    test "creates exception from map with string keys" do
      error = ExNylas.FileError.exception(%{
        "path" => "/data/file.csv",
        "reason" => :enospc,
        "message" => "No space left on device"
      })

      assert error.message == "No space left on device"
      assert error.path == "/data/file.csv"
      assert error.reason == :enospc
    end
  end

  describe "exception/1 with struct input" do
    test "creates exception from existing error struct with message" do
      original = %ExNylas.FileError{
        message: "Custom file error",
        path: "/tmp/file.txt",
        reason: :eacces
      }

      error = ExNylas.FileError.exception(original)

      assert error.message == "Custom file error"
      assert error.path == "/tmp/file.txt"
      assert error.reason == :eacces
    end

    test "generates message from path and reason when message is nil" do
      original = %ExNylas.FileError{
        message: nil,
        path: "/etc/config.conf",
        reason: :eacces
      }

      error = ExNylas.FileError.exception(original)

      assert error.message == "Failed to read file at /etc/config.conf: permission denied"
      assert error.path == "/etc/config.conf"
      assert error.reason == :eacces
    end

    test "generates message from reason only when path is nil" do
      original = %ExNylas.FileError{
        message: nil,
        path: nil,
        reason: :enoent
      }

      error = ExNylas.FileError.exception(original)

      assert error.message == "File operation failed: file does not exist"
      assert error.reason == :enoent
    end
  end

  describe "message/1 callback" do
    test "returns the error message" do
      error = %ExNylas.FileError{
        message: "Cannot read file",
        path: "/file.txt",
        reason: :enoent
      }

      assert Exception.message(error) == "Cannot read file"
    end

    test "returns default message when nil" do
      error = %ExNylas.FileError{message: nil, path: nil, reason: :unknown}

      assert Exception.message(error) == "File operation failed"
    end
  end

  describe "format_reason/1 coverage" do
    test "formats enotdir error" do
      error = ExNylas.FileError.exception({"/path", :enotdir})
      assert error.message =~ "not a directory"
    end

    test "formats enomem error" do
      error = ExNylas.FileError.exception({"/path", :enomem})
      assert error.message =~ "not enough memory"
    end

    test "formats enospc error" do
      error = ExNylas.FileError.exception({"/path", :enospc})
      assert error.message =~ "no space left on device"
    end
  end

  describe "exception type verification" do
    test "is an exception" do
      error = ExNylas.FileError.exception({"/file.txt", :enoent})

      assert Exception.exception?(error)
    end

    test "implements Exception behavior" do
      behaviours =
        ExNylas.FileError.__info__(:attributes)
        |> Keyword.get_values(:behaviour)
        |> List.flatten()

      assert Exception in behaviours
    end
  end
end
