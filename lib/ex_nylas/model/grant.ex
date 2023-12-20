defmodule ExNylas.Model.Grant do
  @moduledoc """
  A struct represting a Nylas grant.
  """

  use TypedStruct

  typedstruct do
    field(:id, String.t())
    field(:provider, String.t())
    field(:grant_status, String.t())
    field(:email, String.t())
    field(:scope, [String.t()])
    field(:user_agent, String.t())
    field(:ip, String.t())
    field(:state, String.t())
    field(:created_at, String.t())
    field(:updated_at, String.t())
  end

  def as_struct, do: struct(__MODULE__)

  def as_list, do: [as_struct()]
end
