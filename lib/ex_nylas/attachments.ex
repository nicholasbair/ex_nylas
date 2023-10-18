defmodule ExNylas.Attachments do
  @moduledoc """
  Interface for Nylas file.
  """

  use ExNylas,
    object: "files",
    struct: ExNylas.Model.Attachment,
    include: [:find]
end
