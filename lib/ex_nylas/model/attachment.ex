defmodule ExNylas.Model.Attachment do
  @moduledoc """
  A struct representing an attachment.
  """

  use TypedStruct

  typedstruct do
    field(:id, String.t())
    field(:grant_id, String.t())
    field(:content_type, String.t())
    field(:content, String.t())
    field(:size, non_neg_integer())
    field(:filename, String.t())
    field(:is_inline, boolean())
    field(:content_disposition, String.t())
  end

  def as_struct, do: struct(__MODULE__)

  def as_list, do: [as_struct()]
end
