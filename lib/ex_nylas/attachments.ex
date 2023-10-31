defmodule ExNylas.Attachments do
  @moduledoc """
  Interface for Nylas file.
  """

  use ExNylas,
    object: "files",
    struct: ExNylas.Model.Attachment,
    readable_name: "attachment",
    include: [:find]
end
