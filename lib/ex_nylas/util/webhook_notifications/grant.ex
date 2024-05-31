defmodule ExNylas.WebhookNotification.Grant do
  @moduledoc """
  A struct representing a grant webhook notification.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:code, :integer)
    field(:grant_id, :string, null: false)
    field(:integration_id, :string)
    field(:provider, :string)
    field(:reauthentication_flag, :boolean)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:code, :grant_id, :integration_id, :provider, :reauthentication_flag])
  end
end
