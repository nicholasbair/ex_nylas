defmodule ExNylas.AttachmentTest do
  use ExUnit.Case, async: true
  alias ExNylas.Attachment

  describe "Attachment schema" do
    test "creates a valid attachment with all fields" do
      params = %{
        "content_disposition" => "attachment",
        "content_id" => "cid:123",
        "content_type" => "image/jpeg",
        "filename" => "photo.jpg",
        "grant_id" => "grant_123",
        "id" => "attachment_123",
        "is_inline" => false,
        "size" => 1024
      }

      changeset = Attachment.changeset(%Attachment{}, params)
      assert changeset.valid?
      attachment = Ecto.Changeset.apply_changes(changeset)
      assert attachment.content_disposition == "attachment"
      assert attachment.content_id == "cid:123"
      assert attachment.content_type == "image/jpeg"
      assert attachment.filename == "photo.jpg"
      assert attachment.grant_id == "grant_123"
      assert attachment.id == "attachment_123"
      assert attachment.is_inline == false
      assert attachment.size == 1024
    end

    test "handles boolean is_inline field correctly" do
      # Test true value
      params = %{"is_inline" => true}
      changeset = Attachment.changeset(%Attachment{}, params)
      assert changeset.valid?
      attachment = Ecto.Changeset.apply_changes(changeset)
      assert attachment.is_inline == true

      # Test false value
      params = %{"is_inline" => false}
      changeset = Attachment.changeset(%Attachment{}, params)
      assert changeset.valid?
      attachment = Ecto.Changeset.apply_changes(changeset)
      assert attachment.is_inline == false
    end

    test "handles size field with non-negative integers" do
      valid_sizes = [0, 1, 1024, 1_000_000]
      for size <- valid_sizes do
        params = %{"size" => size}
        changeset = Attachment.changeset(%Attachment{}, params)
        assert changeset.valid?, "Size #{size} should be valid"
        attachment = Ecto.Changeset.apply_changes(changeset)
        assert attachment.size == size
      end
    end

    test "handles nil size value" do
      params = %{"size" => nil}
      changeset = Attachment.changeset(%Attachment{}, params)
      assert changeset.valid?
      attachment = Ecto.Changeset.apply_changes(changeset)
      assert attachment.size == nil
    end

    test "handles nil values for all fields gracefully" do
      params = %{
        "content_disposition" => nil,
        "content_id" => nil,
        "content_type" => nil,
        "filename" => nil,
        "grant_id" => nil,
        "id" => nil,
        "is_inline" => nil,
        "size" => nil
      }
      changeset = Attachment.changeset(%Attachment{}, params)
      assert changeset.valid?
      attachment = Ecto.Changeset.apply_changes(changeset)
      assert attachment.content_disposition == nil
      assert attachment.content_id == nil
      assert attachment.content_type == nil
      assert attachment.filename == nil
      assert attachment.grant_id == nil
      assert attachment.id == nil
      assert attachment.is_inline == nil
      assert attachment.size == nil
    end

    test "creates minimal attachment with only required fields" do
      params = %{
        "id" => "attachment_123",
        "content_type" => "text/plain"
      }
      changeset = Attachment.changeset(%Attachment{}, params)
      assert changeset.valid?
      attachment = Ecto.Changeset.apply_changes(changeset)
      assert attachment.id == "attachment_123"
      assert attachment.content_type == "text/plain"
    end
  end
end
