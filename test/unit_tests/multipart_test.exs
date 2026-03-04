defmodule ExNylasTest.Multipart do
  use ExUnit.Case, async: true

  alias ExNylas.Multipart, as: NylasMultipart
  alias ExNylas.Multipart.Attachment

  describe "build_multipart/2 with Attachment struct" do
    test "binary content" do
      content = "hello world"

      attachment = %Attachment{
        filename: "test.txt",
        content: content,
        size: byte_size(content)
      }

      assert {:ok, {body_stream, content_type, content_length}} =
               NylasMultipart.build_multipart(%{subject: "test"}, [attachment])

      body = body_stream |> Enum.join("")
      assert String.contains?(content_type, "multipart/form-data")
      assert content_length > 0
      assert String.contains?(body, "hello world")
      assert String.contains?(body, "test.txt")
      assert String.contains?(body, "text/plain")
    end

    test "stream content" do
      chunks = ["streamed ", "data"]
      stream = Stream.map(chunks, & &1)
      total_size = chunks |> Enum.join("") |> byte_size()

      attachment = %Attachment{
        filename: "data.txt",
        content: stream,
        size: total_size
      }

      assert {:ok, {body_stream, content_type, content_length}} =
               NylasMultipart.build_multipart(%{subject: "test"}, [attachment])

      body = body_stream |> Enum.join("")
      assert String.contains?(content_type, "multipart/form-data")
      assert content_length > 0
      assert String.contains?(body, "streamed ")
      assert String.contains?(body, "data")
      assert String.contains?(body, "data.txt")
    end

    test "with content_id" do
      content = "image data"

      attachment = %Attachment{
        filename: "logo.png",
        content: content,
        size: byte_size(content),
        content_id: "logo-cid"
      }

      assert {:ok, {body_stream, _content_type, _content_length}} =
               NylasMultipart.build_multipart(%{subject: "test"}, [attachment])

      body = body_stream |> Enum.join("")
      assert String.contains?(body, "logo-cid")
      assert String.contains?(body, "logo.png")
      assert String.contains?(body, "image/png")
    end

    test "mixed struct and file path attachments" do
      # Create a temp file for the file path attachment
      tmp_path = Path.join(System.tmp_dir!(), "multipart_test_#{:erlang.unique_integer([:positive])}.txt")
      File.write!(tmp_path, "file content")

      struct_attachment = %Attachment{
        filename: "stream.txt",
        content: "stream content",
        size: byte_size("stream content")
      }

      assert {:ok, {body_stream, _content_type, _content_length}} =
               NylasMultipart.build_multipart(%{subject: "test"}, [struct_attachment, tmp_path])

      body = body_stream |> Enum.join("")
      assert String.contains?(body, "stream content")
      assert String.contains?(body, "file content")
    after
      tmp_path = Path.join(System.tmp_dir!(), "multipart_test_*.txt")

      Path.wildcard(tmp_path)
      |> Enum.each(&File.rm/1)
    end

    test "content-type derived from filename" do
      attachment = %Attachment{
        filename: "report.pdf",
        content: "pdf data",
        size: byte_size("pdf data")
      }

      assert {:ok, {body_stream, _content_type, _content_length}} =
               NylasMultipart.build_multipart(%{subject: "test"}, [attachment])

      body = body_stream |> Enum.join("")
      assert String.contains?(body, "application/pdf")
    end
  end

  describe "Attachment.from_file/1" do
    test "reads file and builds attachment" do
      tmp_path = Path.join(System.tmp_dir!(), "from_file_test_#{:erlang.unique_integer([:positive])}.txt")
      File.write!(tmp_path, "file content")

      assert {:ok, %Attachment{} = attachment} = Attachment.from_file(tmp_path)
      assert attachment.filename == Path.basename(tmp_path)
      assert attachment.content == "file content"
      assert attachment.size == byte_size("file content")
      assert attachment.content_id == nil
    after
      Path.wildcard(Path.join(System.tmp_dir!(), "from_file_test_*.txt"))
      |> Enum.each(&File.rm/1)
    end

    test "returns error for missing file" do
      assert {:error, %ExNylas.FileError{} = error} = Attachment.from_file("/nonexistent/file.txt")
      assert error.reason == :enoent
    end
  end

  describe "Attachment.from_file/2" do
    test "reads file and sets content_id" do
      tmp_path = Path.join(System.tmp_dir!(), "from_file_cid_test_#{:erlang.unique_integer([:positive])}.txt")
      File.write!(tmp_path, "inline content")

      assert {:ok, %Attachment{} = attachment} = Attachment.from_file(tmp_path, "my-cid")
      assert attachment.content_id == "my-cid"
      assert attachment.content == "inline content"
    after
      Path.wildcard(Path.join(System.tmp_dir!(), "from_file_cid_test_*.txt"))
      |> Enum.each(&File.rm/1)
    end
  end

  describe "deprecated formats" do
    test "file path string still works" do
      tmp_path = Path.join(System.tmp_dir!(), "deprecated_test_#{:erlang.unique_integer([:positive])}.txt")
      File.write!(tmp_path, "deprecated content")

      assert {:ok, {body_stream, _content_type, _content_length}} =
               NylasMultipart.build_multipart(%{subject: "test"}, [tmp_path])

      body = body_stream |> Enum.join("")
      assert String.contains?(body, "deprecated content")
    after
      Path.wildcard(Path.join(System.tmp_dir!(), "deprecated_test_*.txt"))
      |> Enum.each(&File.rm/1)
    end

    test "tuple format still works" do
      tmp_path = Path.join(System.tmp_dir!(), "deprecated_tuple_test_#{:erlang.unique_integer([:positive])}.txt")
      File.write!(tmp_path, "tuple content")

      assert {:ok, {body_stream, _content_type, _content_length}} =
               NylasMultipart.build_multipart(%{subject: "test"}, [{"my-cid", tmp_path}])

      body = body_stream |> Enum.join("")
      assert String.contains?(body, "tuple content")
    after
      Path.wildcard(Path.join(System.tmp_dir!(), "deprecated_tuple_test_*.txt"))
      |> Enum.each(&File.rm/1)
    end
  end
end
