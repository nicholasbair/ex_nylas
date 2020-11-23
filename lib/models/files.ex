defmodule ExNylas.File do
  @moduledoc """
  A struct representing a file.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A file"
    field :id,                  String.t()
    field :object,              String.t()
    field :account_id,          String.t()
    field :content_type,        String.t()
    field :size,                non_neg_integer()
    field :filename,            String.t()
    field :message_ids,         list()
    field :content_id,          String.t()
    field :content_disposition, String.t()
  end

end

defmodule ExNylas.Files do
  @moduledoc """
  Interface for Nylas file.
  """

  use ExNylas, object: "files", struct: ExNylas.File, except: [:search, :send]

  # TODO:
  # 1. GET /files/{id}/download
  # 2. POST /files


end
