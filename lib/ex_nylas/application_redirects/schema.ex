defmodule ExNylas.ApplicationRedirect do
  @moduledoc """
  A struct for Nylas application redirect.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/applications)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:platform, Ecto.Enum, values: ~w(web desktop js ios android)a)
    field(:url, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
